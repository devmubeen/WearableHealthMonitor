// src/services/healthDataModel.js
export class HealthDataModel {
    constructor(deviceType, deviceId) {
        this.deviceType = deviceType;
        this.deviceId = deviceId;
        this.timestamp = new Date().toISOString();
        this.data = {
            heartRate: null,
            steps: null,
            calories: null,
            distance: null,
            sleep: {
                duration: null,
                quality: null,
                stages: []
            },
            bloodOxygen: null,
            temperature: null,
            bloodPressure: {
                systolic: null,
                diastolic: null
            },
            activity: {
                type: null,
                duration: null,
                intensity: null
            }
        };
        this.metadata = {
            batteryLevel: null,
            firmwareVersion: null,
            lastSync: null
        };
    }

    updateHeartRate(value) {
        this.data.heartRate = value;
        return this;
    }

    updateSteps(value) {
        this.data.steps = value;
        return this;
    }

    updateTemperature(value) {
        this.data.temperature = value;
        return this;
    }

    updateBatteryLevel(value) {
        this.metadata.batteryLevel = value;
        return this;
    }

    toJSON() {
        return {
            deviceType: this.deviceType,
            deviceId: this.deviceId,
            timestamp: this.timestamp,
            data: this.data,
            metadata: this.metadata
        };
    }
}