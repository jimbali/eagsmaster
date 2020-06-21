import Handsontable from 'handsontable'

const afterChange = (change, source) => {
  if (source === 'loadData') return

  clearTimeout(autosaveNotification)
  row = data[change[0][0]]
  key = change[0][1]
  questionId = row['id']
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
    questionsConsole.innerText  = 'Autosaved (' + change.length + ' ' + 'cell' + (change.length > 1 ? 's' : '') + ')'
    autosaveNotification = setTimeout(function() {
      questionsConsole.innerText = 'Changes will be autosaved'
    }, 2000)
  })
}

const beforeRemoveRow = (index, amount, physicalRows, source) => {
  for(let i = 0; i < physicalRows.length; i++) {
    index = physicalRows[i]
    id = data[index].id
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
      questionsConsole.innerText = 'Autosaved (row deleted)'
      autosaveNotification = setTimeout(function() {
        questionsConsole.innerText = 'Changes will be autosaved'
      }, 2000)
    })
  }
}

let autosaveNotification
const questionsConsole = document.getElementById('questions-console')
const questionsContainer = document.getElementById('questions-root')
const data = JSON.parse(questionsContainer.dataset.quizJson)
const token = document.querySelector('meta[name="csrf-token"]').content
const baseUrl = questionsContainer.dataset.baseUrl
const hot = new Handsontable(questionsContainer, {
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
