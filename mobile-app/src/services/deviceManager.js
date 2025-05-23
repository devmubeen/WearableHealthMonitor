// src/services/deviceManager.js
import AsyncStorage from '@react-native-async-storage/async-storage';
import { NativeEventEmitter, NativeModules } from 'react-native';
import BleManager from 'react-native-ble-manager';
import Config from 'react-native-config';

const BleManagerModule = NativeModules.BleManager;
const bleManagerEmitter = new NativeEventEmitter(BleManagerModule);

// Device type definitions
export const DEVICE_TYPES = {
    FITBIT: 'fitbit',
    APPLE_WATCH: 'apple_watch',
    GARMIN: 'garmin',
    SAMSUNG: 'samsung',
    MI_BAND: 'mi_band',
    GENERIC_BLE: 'generic_ble',
    CUSTOM_IOT: 'custom_iot'
};

class DeviceManager {
    constructor() {
        this.connectedDevices = new Map();
        this.isInitialized = false;
        this.listeners = [];
    }

    async initialize() {
        try {
            // Initialize BLE Manager
            await BleManager.start({ showAlert: false });

            // Set up event listeners
            this.setupEventListeners();

            this.isInitialized = true;
            console.log('Device Manager initialized successfully');
        } catch (error) {
            console.error('Failed to initialize Device Manager:', error);
            throw error;
        }
    }

    setupEventListeners() {
        // BLE device discovery
        this.listeners.push(
            bleManagerEmitter.addListener('BleManagerDiscoverPeripheral', (device) => {
                console.log('Discovered device:', device.name || device.id);
            })
        );

        // BLE device connection status
        this.listeners.push(
            bleManagerEmitter.addListener('BleManagerConnectPeripheral', (args) => {
                console.log('Device connected:', args.peripheral);
            })
        );

        this.listeners.push(
            bleManagerEmitter.addListener('BleManagerDisconnectPeripheral', (args) => {
                console.log('Device disconnected:', args.peripheral);
                this.connectedDevices.delete(args.peripheral);
            })
        );

        // BLE characteristic updates
        this.listeners.push(
            bleManagerEmitter.addListener('BleManagerDidUpdateValueForCharacteristic', (data) => {
                this.handleCharacteristicUpdate(data);
            })
        );
    }

    async scanForDevices(duration = 10) {
        try {
            console.log('Scanning for devices...');
            await BleManager.scan([], duration, false);

            // Get discovered devices after scan
            const devices = await BleManager.getDiscoveredPeripherals();

            return devices.map(device => ({
                id: device.id,
                name: device.name || 'Unknown Device',
                rssi: device.rssi,
                type: this.identifyDeviceType(device)
            }));
        } catch (error) {
            console.error('Scan error:', error);
            throw error;
        }
    }

    identifyDeviceType(device) {
        const name = (device.name || '').toLowerCase();

        if (name.includes('fitbit')) return DEVICE_TYPES.FITBIT;
        if (name.includes('apple watch')) return DEVICE_TYPES.APPLE_WATCH;
        if (name.includes('garmin')) return DEVICE_TYPES.GARMIN;
        if (name.includes('galaxy')) return DEVICE_TYPES.SAMSUNG;
        if (name.includes('mi band')) return DEVICE_TYPES.MI_BAND;

        // Check service UUIDs for known health services
        if (device.serviceUUIDs) {
            // Heart Rate Service
            if (device.serviceUUIDs.includes('180D')) return DEVICE_TYPES.GENERIC_BLE;
            // Health Thermometer Service
            if (device.serviceUUIDs.includes('1809')) return DEVICE_TYPES.GENERIC_BLE;
        }

        return DEVICE_TYPES.CUSTOM_IOT;
    }

    async connectToDevice(deviceId, deviceType) {
        try {
            await BleManager.connect(deviceId);

            // Discover services and characteristics
            const deviceInfo = await BleManager.retrieveServices(deviceId);

            // Store device info
            this.connectedDevices.set(deviceId, {
                id: deviceId,
                type: deviceType,
                services: deviceInfo.services,
                characteristics: deviceInfo.characteristics
            });

            // Subscribe to relevant characteristics based on device type
            await this.subscribeToHealthData(deviceId, deviceType);

            return deviceInfo;
        } catch (error) {
            console.error('Connection error:', error);
            throw error;
        }
    }

    async subscribeToHealthData(deviceId, deviceType) {
        // Standard BLE health service UUIDs
        const healthServices = {
            heartRate: { service: '180D', characteristic: '2A37' },
            batteryLevel: { service: '180F', characteristic: '2A19' },
            bodyTemperature: { service: '1809', characteristic: '2A1C' }
        };

        for (const [dataType, uuids] of Object.entries(healthServices)) {
            try {
                await BleManager.startNotification(
                    deviceId,
                    uuids.service,
                    uuids.characteristic
                );
                console.log(`Subscribed to ${dataType} notifications`);
            } catch (error) {
                console.log(`${dataType} service not available on this device`);
            }
        }
    }

    handleCharacteristicUpdate(data) {
        const { peripheral, characteristic, value } = data;
        const device = this.connectedDevices.get(peripheral);

        if (!device) return;

        // Parse data based on characteristic UUID
        const parsedData = this.parseHealthData(characteristic, value, device.type);

        if (parsedData) {
            console.log('Health data received:', parsedData);
            // We'll send this to IoT Hub in the next step
        }
    }

    parseHealthData(characteristicUUID, value, deviceType) {
        // Convert byte array to appropriate data format
        const bytes = new Uint8Array(value);

        switch (characteristicUUID.toUpperCase()) {
            case '2A37': // Heart Rate
                return {
                    type: 'heartRate',
                    value: bytes[1],
                    unit: 'bpm',
                    timestamp: new Date().toISOString()
                };

            case '2A19': // Battery Level
                return {
                    type: 'batteryLevel',
                    value: bytes[0],
                    unit: '%',
                    timestamp: new Date().toISOString()
                };

            case '2A1C': // Body Temperature
                const temp = (bytes[1] << 8) | bytes[0];
                return {
                    type: 'temperature',
                    value: temp / 10.0,
                    unit: '°C',
                    timestamp: new Date().toISOString()
                };

            default:
                console.log(`Unknown characteristic: ${characteristicUUID}`);
                return null;
        }
    }

    async disconnectDevice(deviceId) {
        try {
            await BleManager.disconnect(deviceId);
            this.connectedDevices.delete(deviceId);
        } catch (error) {
            console.error('Disconnect error:', error);
        }
    }

    async cleanup() {
        // Remove all listeners
        this.listeners.forEach(listener => listener.remove());
        this.listeners = [];

        // Disconnect all devices
        const deviceIds = Array.from(this.connectedDevices.keys());
        await Promise.all(deviceIds.map(id => this.disconnectDevice(id)));
    }
}

export default new DeviceManager();