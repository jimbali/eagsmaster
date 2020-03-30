const { environment } = require('@rails/webpacker')

environment.config.merge({
  output: {
    library: ['Packs', '[name]'], // exports to "Packs.application" from application pack
    libraryTarget: 'var',
  }
})

module.exports = environment
