/**
 * SAA1099Tracker: Serial Streamer for hardware output
 * Copyright (c) 2012-2025 Martin Borik <martin@borik.net>
 * Copyright (c) 2026 Dimitar Angelov
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

import { SAASoundRegisters } from '../libs/SAASound/SAASound';
import { devLog } from './dev';

export type StreamMode = 'software' | 'hardware' | 'both';

export interface StreamStats {
  framesSent: number;
  bytesSent: number;
  lastFrameTime: number;
  isConnected: boolean;
  lastFrameData: string;
  portName: string;
  error: string;
}

export interface SerialDebugMessage {
  timestamp: string;
  section: string;
  message: string;
}

export default class SerialStreamer {
  private port: any = null;
  private mode: StreamMode = 'software';
  private stats: StreamStats = {
    framesSent: 0,
    bytesSent: 0,
    lastFrameTime: 0,
    isConnected: false,
    lastFrameData: '',
    portName: '',
    error: '',
  };
  private _debugLog: SerialDebugMessage[] = [];
  private readonly MAX_DEBUG_LOG = 500;
  private lastDebugTime = 0;
  private debugThrottleMs = 100;
  public onDataReceived: ((line: string) => void) | null = null;
  private reader: any = null;

  constructor() {
    this.setupListeners();
  }

  /**
   * Setup connect/disconnect event listeners - following working example pattern
   */
  private async setupListeners(): Promise<void> {
    try {
      navigator.serial.addEventListener('connect', (_event) => {
        this.addDebugLog('SerialStreamer', 'Device connected');
        devLog('SerialStreamer', 'Device connected');
      });

      navigator.serial.addEventListener('disconnect', (event) => {
        this.addDebugLog('SerialStreamer', 'Device disconnected');
        devLog('SerialStreamer', 'Device disconnected');
        if (this.port === event.target) {
          this.disconnect();
          this.tryAutoReconnect();
        }
      });

      this.addDebugLog('SerialStreamer', 'Event listeners registered');
    }
    catch (error) {
      this.addDebugLog('SerialStreamer', 'Error setting up listeners: ' + error);
    }
  }

  /**
   * Get all buffered debug log entries
   */
  public getDebugLog(): SerialDebugMessage[] {
    return [...this._debugLog];
  }

  /**
   * Clear all buffered debug log entries
   */
  public clearDebugLog(): void {
    this._debugLog = [];
  }

  /**
   * Add a timestamped debug message to the internal buffer
   */
  private addDebugLog(section: string, message: string): void {
    this._debugLog.push({
      timestamp: new Date().toISOString(),
      section,
      message,
    });

    if (this._debugLog.length > this.MAX_DEBUG_LOG) {
      this._debugLog.shift();
    }
  }

  /**
   * Check if Web Serial API is supported - just try to use it like working example
   */
  public isSupported(): boolean {
    try {
      // Just try to access navigator.serial - if it works, it's supported
      void navigator.serial;
      return true;
    }
    catch {
      return false;
    }
  }

  /**
   * Get current connection status
   */
  public isConnected(): boolean {
    return this.stats.isConnected && this.port !== null;
  }

  /**
   * Get current streaming mode
   */
  public getMode(): StreamMode {
    return this.mode;
  }

  /**
   * Set streaming mode
   */
  public setMode(mode: StreamMode): void {
    this.mode = mode;
    devLog('SerialStreamer', 'Mode changed to:', mode);
  }

  /**
   * Get current statistics
   */
  public getStats(): StreamStats {
    return { ...this.stats };
  }

  /**
   * Get available serial ports - following working example pattern
   */
  public async getAvailablePorts(): Promise<any[]> {
    try {
      this.addDebugLog('SerialStreamer', 'Getting available ports...');
      const ports = await navigator.serial.getPorts();
      this.addDebugLog('SerialStreamer', 'Found ' + ports.length + ' ports with permission');
      return ports;
    }
    catch (error) {
      const msg = 'Failed to get available ports: ' + error;
      console.error(msg);
      this.addDebugLog('SerialStreamer', msg);
      return [];
    }
  }

  /**
   * Get a user-friendly port name
   */
  private getPortName(port: any): string {
    const info = port.getInfo();
    const vendorId = info.usbVendorId ? '0x' + info.usbVendorId.toString(16).padStart(4, '0') : null;
    const productId = info.usbProductId ? '0x' + info.usbProductId.toString(16).padStart(4, '0') : null;

    if (vendorId && productId) {
      return `USB Device (${vendorId}:${productId})`;
    }
    return 'Serial Port';
  }

  /**
   * Connect to a serial port - following working example pattern exactly
   */
  public async connect(baudRate: number = 115200, existingPort?: any): Promise<boolean> {
    if (this.isConnected()) {
      return true;
    }

    try {
      let port: any;
      if (existingPort) {
        port = existingPort;
      }
      else {
        // Request port from user - exactly like working example
        port = await navigator.serial.requestPort();
      }

      // Open the port
      await port.open({ baudRate });

      this.port = port;
      this.stats.isConnected = true;
      this.stats.framesSent = 0;
      this.stats.bytesSent = 0;
      this.stats.error = '';
      this.stats.portName = this.getPortName(port);

      // Save port info to localStorage for auto-reconnect (like working example)
      const portInfo = port.getInfo();
      if (portInfo.usbVendorId && portInfo.usbProductId) {
        localStorage.setItem('saa1099_serial_vid', String(portInfo.usbVendorId));
        localStorage.setItem('saa1099_serial_pid', String(portInfo.usbProductId));
      }

      this.startReadLoop();

      return true;
    }
    catch (error) {
      this.stats.error = (error as Error).message || 'Connection failed';
      await this.disconnect();
      return false;
    }
  }

  /**
   * Try to auto-reconnect to previously used port - following working example pattern
   */
  public async tryAutoReconnect(): Promise<boolean> {
    try {
      const savedVid = parseInt(localStorage.getItem('saa1099_serial_vid') || '0');
      const savedPid = parseInt(localStorage.getItem('saa1099_serial_pid') || '0');

      if (!savedVid || !savedPid) {
        return false;
      }

      const ports = await navigator.serial.getPorts();

      const port = ports.find((p: any) => {
        const info = p.getInfo();
        return info.usbVendorId === savedVid && info.usbProductId === savedPid;
      });

      if (!port) {
        return false;
      }

      await port.open({ baudRate: 115200 });

      this.port = port;
      this.stats.isConnected = true;
      this.stats.portName = this.getPortName(port);

      return true;
    }
    catch (error) {
      return false;
    }
  }

  private async startReadLoop(): Promise<void> {
    if (!this.port?.readable) {
      return;
    }
    this.reader = this.port.readable.getReader();
    let buf = '';
    try {
      while (true) {
        const { value, done } = await this.reader.read();
        if (done) {
          break;
        }
        buf += new TextDecoder().decode(value, { stream: true });
        const lines = buf.split('\n');
        buf = lines.pop() || '';
        for (const line of lines) {
          const trimmed = line.replace(/\r$/, '');
          if (trimmed && this.onDataReceived) {
            this.onDataReceived(trimmed);
          }
        }
      }
    }
    catch (error) {
      this.addDebugLog('SerialStreamer', 'Read loop ended: ' + error);
    }
    finally {
      if (this.reader) {
        this.reader.releaseLock();
        this.reader = null;
      }
    }
  }

  /**
   * Disconnect from serial port - following working example pattern
   */
  public async disconnect(): Promise<void> {
    if (this.reader) {
      try {
        await this.reader.cancel();
      }
      catch {
        // ignore cancel errors
      }
      this.reader = null;
    }

    if (this.port) {
      try {
        this.addDebugLog('SerialStreamer', 'Closing port...');
        await this.port.close();
        this.addDebugLog('SerialStreamer', 'Port closed successfully');
      }
      catch (e) {
        this.addDebugLog('SerialStreamer', `Error closing port: ${e}`);
        // Ignore close errors
      }
      this.port = null;
    }

    this.stats.isConnected = false;
    devLog('SerialStreamer', 'Disconnected from serial port');
    this.addDebugLog('SerialStreamer', 'Disconnected from serial port');
  }

  /**
   * Send a frame of register data to hardware - following working example pattern
   * Protocol: [0xFF SYNC][32 bytes registers][CHECKSUM]
   */
  public async sendFrame(regs: SAASoundRegisters, positionInfo?: { pattern: number; row: number }): Promise<boolean> {
    const now = Date.now();
    const shouldLog = (now - this.lastDebugTime) >= this.debugThrottleMs;

    // Build packet: sync byte + 32 registers + checksum
    const packet = new Uint8Array(34);
    let checksum = 0;

    // Sync byte
    packet[0] = 0xFF;

    // Fill packet with register values (0x00-0x1F)
    for (let i = 0; i < 32; i++) {
      const regAddr = i;
      const key = 'R' + regAddr.toString(16).toUpperCase().padStart(2, '0');
      const value = regs[key] || 0;
      packet[i + 1] = value;
      checksum ^= value;
    }

    // Checksum (XOR of all register values)
    packet[33] = checksum;

    // Store last frame data for display
    const frameHex = Array.from(packet).map(b => b.toString(16).padStart(2, '0')).join(' ');
    this.stats.lastFrameData = frameHex;

    // Log the frame data ALWAYS (for debugging) - throttled
    if (shouldLog) {
      this.lastDebugTime = now;
      const posStr = positionInfo ? '[Pos:' + positionInfo.pattern + ' Row:' + positionInfo.row + '] ' : '';
      devLog('SerialStreamer', posStr + frameHex);
      this.addDebugLog('SerialStreamer', posStr + frameHex.substring(0, 50));
    }

    // Only send if in hardware or both mode and connected
    if (this.mode === 'software') {
      return true;
    }

    if (!this.isConnected() || !this.port) {
      if (shouldLog) {
        this.addDebugLog('SerialStreamer', 'Not connected - data not sent to hardware');
      }
      return false;
    }

    try {
      // Following working example: get writer, write, then close (not releaseLock)
      this.addDebugLog('SerialStreamer', 'Getting writable writer...');
      const writer = this.port.writable.getWriter();

      this.addDebugLog('SerialStreamer', 'Writing ' + packet.length + ' bytes...');
      await writer.write(packet);
      this.addDebugLog('SerialStreamer', 'Write successful');

      // Working example uses close() instead of releaseLock()
      this.addDebugLog('SerialStreamer', 'Closing writer...');
      await writer.close();
      this.addDebugLog('SerialStreamer', 'Writer closed');

      // Update stats
      this.stats.framesSent++;
      this.stats.bytesSent += packet.length;
      this.stats.lastFrameTime = Date.now();

      return true;
    }
    catch (error) {
      const errorMsg = 'Failed to send frame: ' + error;
      console.error(errorMsg);
      this.addDebugLog('SerialStreamer', errorMsg);
      this.stats.error = (error as Error).message || 'Send failed';
      await this.disconnect();
      return false;
    }
  }

  /**
   * Clear saved port from localStorage
   */
  public clearSavedPort(): void {
    localStorage.removeItem('saa1099_serial_vid');
    localStorage.removeItem('saa1099_serial_pid');
    this.addDebugLog('SerialStreamer', 'Saved port info cleared from localStorage');
  }
}
