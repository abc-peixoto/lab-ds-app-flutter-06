const logLevels = {
  error: 0,
  warn: 1,
  info: 2,
  debug: 3,
};

const currentLogLevel = logLevels[process.env.LOG_LEVEL as keyof typeof logLevels] ?? logLevels.info;

export const logger = {
  error: (...args: any[]) => {
    if (currentLogLevel >= logLevels.error) {
      console.error('[ERROR]', ...args);
    }
  },
  warn: (...args: any[]) => {
    if (currentLogLevel >= logLevels.warn) {
      console.warn('[WARN]', ...args);
    }
  },
  info: (...args: any[]) => {
    if (currentLogLevel >= logLevels.info) {
      console.log('[INFO]', ...args);
    }
  },
  debug: (...args: any[]) => {
    if (currentLogLevel >= logLevels.debug) {
      console.log('[DEBUG]', ...args);
    }
  },
};



