require('dotenv').config()

const path = require('path')
const Dotenv = require('dotenv-webpack')

module.exports = {
  webpack: config => {
    config.plugins = config.plugins || []

    config.plugins = [
      ...config.plugins,
      new Dotenv()
    ]

    return config
  }
}
