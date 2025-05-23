// src/utils/bleUtils.js
export const BLE_SERVICES = {
    HEART_RATE: '180D',
    BATTERY: '180F',
    HEALTH_THERMOMETER: '1809',
    DEVICE_INFORMATION: '180A',
    GENERIC_ACCESS: '1800',
    GENERIC_ATTRIBUTE: '1801'
};

export const BLE_CHARACTERISTICS = {
    HEART_RATE_MEASUREMENT: '2A37',
    BATTERY_LEVEL: '2A19',
    TEMPERATURE_MEASUREMENT: '2A1C',
    MANUFACTURER_NAME: '2A29',
    MODEL_NUMBER: '2A24',
    FIRMWARE_REVISION: '2A26'
};

export const parseManufacturerData = (data) => {
    // Parse manufacturer specific data
    // This would be customized based on your specific devices
    return {
        manufacturerId: data.slice(0, 2),
        data: data.slice(2)
    };
};

export const convertToFahrenheit = (celsius) => {
    return (celsius * 9 / 5) + 32;
};

export const calculateCaloriesBurned = (heartRate, duration, weight, age, gender) => {
    // Simplified calorie calculation
    // Men: ((-55.0969 + (0.6309 x HR) + (0.1988 x W) + (0.2017 x A))/4.184) x T
    // Women: ((-20.4022 + (0.4472 x HR) - (0.1263 x W) + (0.074 x A))/4.184) x T
    const isMale = gender === 'male';
    let calories;

    if (isMale) {
        calories = ((-55.0969 + (0.6309 * heartRate) + (0.1988 * weight) + (0.2017 * age)) / 4.184) * duration;
    } else {
        calories = ((-20.4022 + (0.4472 * heartRate) - (0.1263 * weight) + (0.074 * age)) / 4.184) * duration;
    }

    return Math.round(calories);
};