import $ from 'jquery'
import Handsontable from 'handsontable'

const toastr = require('toastr')

const afterChange = (changes, source) => {
  if (source === 'loadData') return

  clearTimeout(autosaveNotification)

  const change = changes[0]
  const row = data[change[0]]

  const patch = {
    playerId: row.playerId,
    field: change[1],
    oldValue: change[2],
    newValue: change[3]
  }

  fetch(
    updateProgressUrl,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token
      },
      body: JSON.stringify({ patch: patch })
    }
  )
  .then((response) => {
    if (response.status === 409) {
      toastr.error('Did not update! Value has changed since the last refresh.')
    }
    return response.json()
  })
  .then((newData) => {
    quizConsole.text('Autosaved (1 cell)')
    autosaveNotification = setTimeout(function() {
      quizConsole.text('Changes will be autosaved')
    }, 2000)
    data = newData
    hot.loadData(newData)
  })
}

const quizConsole = $('#quiz-console')
const quizContainer = $('#quiz-root')
let data = quizContainer.data('progressJson')
let autosaveNotification
const token = $('meta[name="csrf-token"]').attr('content')
const updateProgressUrl = quizContainer.data('updateProgressUrl')
const hot = new Handsontable(quizContainer[0], {
  data: data,
  rowHeaders: false,
  colHeaders: quizContainer.data('columnHeaders'),
  columns: quizContainer.data('columnData'),
  filters: true,
  dropdownMenu: true,
  licenseKey: 'non-commercial-and-evaluation',
  contextMenu: ['remove_row'],
  manualColumnResize: true,
  afterChange: afterChange
})

$(document).on('ajax:success', '#add-guest-form', event => {
  data = event.detail[0];
  hot.loadData(data);
})

$(() => {
  $('#export-csv').click(() => {
    let exportPlugin = hot.getPlugin('exportFile')
    exportPlugin.downloadFile('csv', { columnHeaders: true })
  })
})
