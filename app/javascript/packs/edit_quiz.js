import $ from 'jquery'
import Handsontable from 'handsontable'

const toastr = require('toastr')

export default class EditQuiz {
  afterChange(changes, source) {
    if (source === 'loadData') return

    clearTimeout(this.autosaveNotification)

    const change = changes[0]
    const row = this.data[change[0]]

    const patch = {
      playerId: row.playerId,
      field: change[1],
      oldValue: change[2],
      newValue: change[3]
    }

    fetch(
      this.updateProgressUrl,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.token
        },
        body: JSON.stringify({ patch: patch })
      }
    )
    .then((response) => {
      if (response.status === 409) {
        toastr.error(
          'Did not update! Value has changed since the last refresh.'
        )
      }
      return response.json()
    })
    .then((newData) => {
      const console = this.quizConsole
      console.text('Autosaved (1 cell)')
      this.autosaveNotification = setTimeout(function() {
        console.text('Changes will be autosaved')
      }, 2000)
      this.data = newData
      this.quizContainer[0].dataset.progressJson = JSON.stringify(this.data)
      this.hot.loadData(newData)
    })
  }

  refreshData() {
    return fetch(
      this.getProgressUrl,
      {
        method: 'GET',
        headers: {
          'X-CSRF-Token': this.token
        }
      }
    )
    .then((response) => {
      return response.json()
    })
    .then((newData) => {
      this.data = newData
      this.quizContainer[0].dataset.progressJson = JSON.stringify(newData)
      this.hot.loadData(newData)
    })
  }

  allIn (questionId) {
    const column = 'question' + questionId + 'Points'
    return this.data.every((row) => {
      return row[column] != null
    })
  }

  constructor() {
    $(document).on('ready turbolinks:load', () => {
      this.quizContainer = $('#quiz-root')
      if (!this.quizContainer.length) return

      this.quizConsole = $('#quiz-console')
      this.data = this.quizContainer.data('progressJson')
      this.autosaveNotification = null
      this.token = $('meta[name="csrf-token"]').attr('content')
      this.updateProgressUrl = this.quizContainer.data('updateProgressUrl')
      this.getProgressUrl = this.quizContainer.data('getProgressUrl')
      this.hot = new Handsontable(this.quizContainer[0], {
        data: this.data,
        rowHeaders: false,
        colHeaders: this.quizContainer.data('columnHeaders'),
        columns: this.quizContainer.data('columnData'),
        filters: true,
        dropdownMenu: true,
        licenseKey: 'non-commercial-and-evaluation',
        contextMenu: ['remove_row'],
        manualColumnResize: true,
        afterChange: this.afterChange.bind(this)
      })

      $('#export-csv').click(() => {
        let exportPlugin = this.hot.getPlugin('exportFile')
        exportPlugin.downloadFile('csv', { columnHeaders: true })
      })

      $(document).on('ajax:success', '#add-guest-form', event => {
        this.data = event.detail[0]
        this.quizContainer[0].dataset.progressJson = JSON.stringify(this.data)
        this.hot.loadData(this.data)
      })
    })
  }
}
