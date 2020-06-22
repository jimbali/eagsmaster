import $ from 'jquery'
import Handsontable from 'handsontable'

const afterChange = (change, source) => {
  if (source === 'loadData') return

  clearTimeout(autosaveNotification)

  const row = data[change[0][0]]
  const key = change[0][1]
  const questionId = row['id']

  fetch(
    baseUrl + '/' + questionId,
    {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token
      },
      body: JSON.stringify(
        { question: { title: row.title, expired: row.expired } }
      )
    }
  )
  .then((response) => {
    return response.json()
  })
  .then((data) => {
    questionsConsole.text(
      'Autosaved (' + change.length + ' ' + 'cell' +
        (change.length > 1 ? 's' : '') + ')'
    )
    autosaveNotification = setTimeout(function() {
      questionsConsole.text('Changes will be autosaved')
    }, 2000)
  })
}

const beforeRemoveRow = (index, amount, physicalRows, source) => {
  for(let i = 0; i < physicalRows.length; i++) {
    const index = physicalRows[i]
    const id = data[index].id

    fetch(
      baseUrl + '/' + id,
      {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        }
      }
    )
    .then((response) => {
      questionsConsole.text('Autosaved (row deleted)')
      autosaveNotification = setTimeout(function() {
        questionsConsole.text('Changes will be autosaved')
      }, 2000)
    })
  }
}

let autosaveNotification
const questionsConsole = $('#questions-console')
const questionsContainer = $('#questions-root')
const data = questionsContainer.data('quizJson')
const token = $('meta[name="csrf-token"]').attr('content')
const baseUrl = questionsContainer.data('baseUrl')
const hot = new Handsontable(questionsContainer[0], {
  data: data,
  rowHeaders: false,
  colHeaders: ['Title', 'Finished answering?'],
  columns: [
    { data: 'title' },
    { data: 'expired', type: 'checkbox' }
  ],
  filters: true,
  dropdownMenu: true,
  licenseKey: 'non-commercial-and-evaluation',
  contextMenu: ['remove_row'],
  afterChange: afterChange,
  beforeRemoveRow: beforeRemoveRow
})
