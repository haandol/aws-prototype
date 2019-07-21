import * as winston from 'winston';

const logger: winston.Logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
  ]
});

if (process.env.NODE_ENV !== 'production') {
  const alignColorsAndTime = winston.format.combine(
      winston.format.colorize({
          all:true
      }),
      winston.format.label({
          label:'[Product]'
      }),
      winston.format.timestamp({
          format:"YYYY-MM-DDTHH:MM:SS"
      }),
      winston.format.printf(
          info => `${info.label}[${info.level}][${info.timestamp}] ${info.message}`
      )
  );

  logger.level = 'debug';
  logger.add(new winston.transports.Console({
    format: winston.format.combine(winston.format.colorize(), alignColorsAndTime)
  }));
}

export default logger;