const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const defaultConfig = getDefaultConfig(__dirname);

const config = {
    resolver: {
        extraNodeModules: {
            buffer: require.resolve('buffer'),
            stream: require.resolve('stream-browserify'),
            util: require.resolve('util'),
        },
    },
};

module.exports = mergeConfig(defaultConfig, config);