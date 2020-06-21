const toastr = require('toastr')

const showFlash = () => {
  const flash = JSON.parse(document.body.dataset.flash)

  flash.forEach((f) => {
    const type = f[0].replace('alert', 'error').replace('notice', 'info')
    toastr[type](f[1])
  })
}

$(() => {
  showFlash()
})
