/**
 * SAA1099Tracker: Clipboard and tracklist manager class and dependent interfaces.
 * Copyright (c) 2015-2025 Martin Borik <martin@borik.net>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom
 * the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
 * OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//---------------------------------------------------------------------------------------

import { clamp, toHex, toWidth, validateAndClamp } from '../commons/number';
import Pattern from '../player/Pattern';
import Sample from '../player/Sample';
import { i18n } from './doc';
import ManagerHistory from './manager.history';
import { TracklistSelection } from './tracklist';
import Tracker from '.';


interface SelectedBlock {
  pt: number;
  pp: Pattern;
  line: number;
  len: number;
}

export default class Manager extends ManagerHistory {
  private _clipboard: Clipboard;
  public pasteSpecialTranspose: number = 0;

  constructor(_parent: Tracker) {
    super(_parent);

    this._clipboard = window?.navigator?.clipboard;
    if (!this._clipboard) {
      console.error('Error: Clipboard API is not supported!');

      // polyfill
      this._clipboard = (() => {
        let content = '';
        return {
          readText: () => Promise.resolve(content),
          writeText: (text: string) => new Promise<void>((resolve) => {
            content = text;
            resolve();
          })
        };
      })() as Clipboard;
    }
  }

  private _getBlock(lengthFallback?: number): SelectedBlock {
    const p = this._parent.player;
    const sel: TracklistSelection = this._parent.tracklist.selection;
    const ch = sel.len ? sel.channel : this._parent.modeEditChannel;
    const line = sel.len ? sel.line : p.line;
    const length = sel.len ? (sel.len + 1) : undefined;
    const pos = p.positions[p.position] ?? p.nullPosition;
    const chn = pos.ch[ch];
    const pt = chn.pattern;

    return {
      pt,
      pp: p.patterns[pt],
      line: line,
      len: length || lengthFallback
    };
  }

  private _historyPushPatternBlock(block: SelectedBlock) {
    this.historyPush({
      pattern: {
        type: 'data',
        index: block.pt,
        data: block.pp.simplify(block.line, block.line + block.len),
        from: block.line
      }
    });
  }

  private _processDataFromClipboard(content: string): Nullable<string[]> {
    let data: string[];
    if (content.startsWith('STMF.trk:[')) {
      try {
        data = JSON.parse(content.slice(9));
      }
      catch (e) {
        return null;
      }
    }
    else if (content.startsWith('ModPlug Tracker ')) {
      const lines = content.split('\n|').slice(1);
      const cmdMapper = [0xC, 1, 2, 3, 4, 3, 4, 5, 0, 9, 0xA, 0xB, 0, 0xB, 0, 0xF];

      let last_volume = 0;
      data = lines.map<string>((line) => {
        const txtTone = line.slice(0, 3);
        const release = txtTone === '===';
        const smp = validateAndClamp({ value: line.slice(3, 5), min: 0, max: 31 });
        const spc = line[5].toLowerCase();
        const spc_data = parseInt(line.slice(6, 8), 10) || 0;
        let tone = release || txtTone === '...' ? 0 : -1;
        let volume = -1;
        let pan = 0;
        let cmd = parseInt(line.slice(8, 9), 16);
        let cmd_data = parseInt(line.slice(9, 11), 16) || 0;
        if (tone < 0) {
          tone = this._parent.player.tones.findIndex((tone) => tone.txt === txtTone);
          if (tone < 0) {
            tone = 0;
          }
        }
        switch (cmd) {
          case 0x8:
            pan = (cmd_data - 128) / 128;
            cmd = cmd_data = 0;
            break;
          case 0xC:
            volume = cmd_data / 4;
            cmd = cmd_data = 0;
            break;
          default:
            cmd = cmdMapper[cmd] || 0;
            cmd_data = cmd ? cmd_data : 0;
            break;
        }
        switch (spc) {
          case 'a':
            cmd = 0xA;
            cmd_data = 0x10 + clamp(Math.round(spc_data / 2), 1, 7);
            break;
          case 'b':
            cmd = 0xA;
            cmd_data = 0x20 - clamp(Math.round(spc_data / 2), 1, 7);
            break;
          case 'v':
            volume = spc_data / 4;
            break;
          case 'p':
            pan = (spc_data - 32) / 32;
            break;
        }

        if (volume >= 0 || pan !== 0) {
          if (volume >= 0) {
            last_volume = volume;
          }
          else {
            volume = last_volume;
          }
          volume =
            clamp(pan > 0 ? (volume * (1 - pan)) : volume, 1, 15) << 4 |
            clamp(pan < 0 ? (volume * (1 - Math.abs(pan))) : volume, 1, 15);
        }
        else {
          volume = 0;
        }

        return `${release ? '--' : toWidth(tone, 2)}${
          smp.toString(32)
        }0${
          toHex(volume, 2)
        }${
          toHex(cmd, 1)
        }${
          toHex(cmd_data, 2)
        }`.toUpperCase();
      });
    }
    return (data instanceof Array && data.length > 0) ? data : null;
  }

  //-------------------------------------------------------------------------------------
  public clearFromTracklist() {
    const block = this._getBlock(1);
    this._historyPushPatternBlock(block);

    block.pp.parse([], block.line, block.len);
  }

  public copyAsPlainTracklist(): Promise<void> {
    const block = this._getBlock(1);
    const data = block.pp.tracklist.slice(block.line, block.line + block.len).map((row) => {
      const col = row.column.replace(/\x7f/g, '.').toUpperCase();
      return `${row.tone} ${col.slice(0, 4)} ${col.slice(4)}`;
    });

    return this._clipboard.writeText(data.join('\n'));
  }

  public copyFromTracklist(): Promise<void> {
    const block = this._getBlock(1);
    const data = block.pp.export(block.line, block.len, false);

    return this._clipboard.writeText('STMF.trk:' + JSON.stringify(data, null, '\t'));
  }

  public async pasteToTracklist(): Promise<boolean> {
    const content = await this._clipboard.readText();
    const data = this._processDataFromClipboard(content);
    if (!data) {
      return false;
    }

    const block = this._getBlock(data.length);
    this._historyPushPatternBlock(block);

    const sel = this._parent.tracklist.selection;
    this._parent.player.line = block.line + block.len;
    if (sel.len > 0) {
      sel.len = 0;
      this._parent.modeEditChannel = sel.channel;
    }

    block.pp.parse(data, block.line, block.len);
    return true;
  }

  public async pasteSpecialCheckContent(): Promise<Pattern> {
    const content = await this._clipboard.readText();
    const data = this._processDataFromClipboard(content);
    if (!data) {
      return null;
    }

    const mockPattern = new Pattern(data.length);
    mockPattern.parse(data, 0, data.length);
    mockPattern.updateTracklist();

    return mockPattern;
  }

  public async pasteSpecialDialog(
    pattern: Pattern,
    processor: typeof Manager.prototype.pasteSpecialToTracklist,
    callback: (done: boolean) => unknown = () => {},
    title = i18n.dialog.paste.title,
    buttonTitle = i18n.dialog.paste.btn
  ): Promise<void> {
    const dialog = $('#paste');
    const keys = this._parent.globalKeyState;

    dialog.on('show.bs.modal', () => {
      keys.inDialog = true;

      dialog.find('.modal-title').text(title);
      dialog.find('.modal-body pre').text(
        pattern.tracklist
          .slice(0, Math.min(8, pattern.end))
          .map((line) =>
            `${line.tone}  ${line.column[0]}  ${line.column[1]}  ${
              line.column.slice(2, 4)}   ${line.column[4]} ${line.column.slice(5)} `
          )
          .join('\n')
          .replace(/\x7f/g, '.')
          .toUpperCase()
      );

      dialog.find('.btn-success').text(buttonTitle).on('click', () => {
        let validParts = false;
        const parts = Array.from(dialog.find('.modal-body input[type=checkbox]'))
          .map((el: HTMLInputElement) => {
            return { name: el.id, value: el.checked };
          })
          .reduce(
            (acc, { name, value }) => {
              acc[name.slice(7).toLowerCase()] = value;
              validParts ||= value;
              return acc;
            }, {} as { [key: string]: boolean }
          );
        if (!validParts) {
          return;
        }
        processor(pattern, parts).then(callback).finally(() => {
          dialog.modal('hide');
        });
      });

    }).on('hide.bs.modal', () => {
      dialog.find('.modal-footer>.btn').off();
      keys.inDialog = false;

    }).modal({
      show: true,
      backdrop: true
    });
  }

  public async pasteSpecialToTracklist(
    pattern: Pattern,
    parts: { [key: string]: boolean }
  ): Promise<boolean> {
    if (!pattern?.end) {
      return false;
    }
    const block = this._getBlock(pattern.end);
    this._historyPushPatternBlock(block);

    for (let src = 0, dest = block.line; src < block.len; src++, dest++) {
      const srcData = pattern.data[src];
      const destData = block.pp.data[dest];
      if (parts.tone) {
        destData.release = srcData.release;
        destData.tone = (destData.release || srcData.tone === 0) ? 0 :
          clamp(srcData.tone + this.pasteSpecialTranspose, 1, 96);
      }
      if (parts.smp) {
        destData.smp = srcData.smp;
      }
      if (parts.orn) {
        destData.orn = srcData.orn;
        destData.orn_release = srcData.orn_release;
      }
      if (parts.vol) {
        destData.volume.byte = srcData.volume.byte;
      }
      if (parts.cmd) {
        destData.cmd = srcData.cmd;
      }
      if (parts.data) {
        destData.cmd_data = srcData.cmd_data;
      }
    }

    block.pp.updateTracklist(block.line, block.len);
    return true;
  }

  //-------------------------------------------------------------------------------------
  public clearSample() {
    const app = this._parent;
    const smp = app.player.samples[app.workingSample];

    smp.name = '';
    smp.loop = 0;
    smp.end = 0;
    smp.releasable = false;
    smp.parse([]);
  }

  public copySample(): Promise<void> {
    const app = this._parent;
    const smp = app.player.samples[app.workingSample];
    const obj = {
      name: smp.name,
      loop: smp.loop,
      end: smp.end,
      releasable: smp.releasable,
      data: smp.export(false)
    };

    return this._clipboard.writeText('STMF.smp:' + JSON.stringify(obj, null, '\t'));
  }

  public async pasteSampleCheckContent(): Promise<Sample> {
    const content = await this._clipboard.readText();
    if (!content.startsWith('STMF.smp:{')) {
      return null;
    }

    let obj: any;
    try {
      obj = JSON.parse(content.slice(9));
      if (!(
        typeof obj === 'object' && obj.data instanceof Array && obj.data.length > 0 &&
        typeof obj.loop === 'number' && typeof obj.end === 'number' &&
        typeof obj.releasable === 'boolean'
      )) {
        return null;
      }
    }
    catch (e) {
      return null;
    }

    const smp = new Sample();
    smp.parse(obj.data);
    smp.name = obj.name;
    smp.loop = obj.loop;
    smp.end = obj.end;
    smp.releasable = obj.releasable;
    return smp;
  }

  public async pasteSample(src: Sample, mask: number = 7): Promise<boolean> {
    if (!(src && src.data instanceof Array && src.data.length > 0)) {
      return false;
    }

    const app = this._parent;
    const idx = app.workingSample;
    const dst = app.player.samples[idx];

    this.historyPushSampleDebounced(idx);
    dst.data.forEach((tick, index) => {
      const dat = src.data[index];
      if (mask & 1) {
        tick.volume.byte = dat.volume.byte;
        tick.enable_freq = dat.enable_freq;
      }
      if (mask & 2) {
        tick.enable_noise = dat.enable_noise;
        tick.noise_value = dat.noise_value;
      }
      if (mask & 4) {
        tick.shift = dat.shift;
      }
    });

    const all = (mask === 7);
    if (all) {
      dst.name = src.name;
      dst.loop = src.loop;
      dst.end = src.end;
      dst.releasable = src.releasable;
    }
    return true;
  }

  //-------------------------------------------------------------------------------------
  public clearOrnament() {
    const app = this._parent;
    const orn = app.player.ornaments[app.workingOrnament];

    orn.name = '';
    orn.data.fill(0);
    orn.loop = orn.end = 0;
  }

  public copyOrnament(): Promise<void> {
    const app = this._parent;
    const orn = app.player.ornaments[app.workingOrnament];
    const obj = {
      name: orn.name,
      loop: orn.loop,
      end: orn.end,
      data: orn.export(false)
    };

    return this._clipboard.writeText('STMF.orn:' + JSON.stringify(obj, null, '\t'));
  }

  public async pasteOrnament(): Promise<boolean> {
    const content = await this._clipboard.readText();
    if (!content.startsWith('STMF.orn:{')) {
      return false;
    }

    const app = this._parent;
    const idx = app.workingOrnament;
    const orn = app.player.ornaments[idx];

    let obj: any;
    try {
      obj = JSON.parse(content.slice(9));
      if (!(typeof obj === 'object' && obj.data instanceof Array && obj.data.length > 0)) {
        return false;
      }
    }
    catch (e) {
      return false;
    }

    this.historyPushOrnamentDebounced(idx);
    orn.parse(obj.data);
    orn.name = obj.name;
    orn.loop = obj.loop;
    orn.end = obj.end;
    return true;
  }
}
