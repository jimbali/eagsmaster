const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.config.merge({
  output: {
    library: ['Packs', '[name]'], // exports to "Packs.application" from application pack
    libraryTarget: 'var',
  }
})

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default']
  })
)

module.exports = environment
