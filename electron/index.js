'use strict';

const { resolve } = require('path');
const { app, BrowserWindow } = require('electron');


let mainWindow;


function createWindow() {
  mainWindow = new BrowserWindow({
    titleBarStyle: 'hidden',
    webPreferences: { nodeIntegration: false, webSecurity: false }
  });

  mainWindow.maximize();
  mainWindow.loadURL(`file://${__dirname}/index.html`);
  mainWindow.on('closed', () => mainWindow = null);
}


app.on('ready', createWindow);
app.on('activate', () => (mainWindow === null) && createWindow());
app.on('window-all-closed', () => (process.platform !== 'darwin') && app.quit());
