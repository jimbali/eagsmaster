import $ from 'jquery'
import Handsontable from 'handsontable'
import cloneDeep from 'lodash/cloneDeep'

export default class Leaderboard {
  #autosaveNotification = null

  afterColumnSort(currentSortConfig, destinationSortConfigs) {
    const config = destinationSortConfigs[0]
    if (!config) {
      this.hot.loadData(cloneDeep(this.originalData))
      return
    }

    this.recaculateRank(config.column, config.sortOrder)
  }

  recaculateRank(column, order) {
    if (!this.hot) return

    let data = this.hot.getData().slice(0)

    let rank = order == 'asc' ? data.length : 1
    let valueMemo = null

    if (order == 'asc') data = data.reverse()

    const newData = data.map((result, i) => {
      const colValue = parseFloat(result[column])

      if (valueMemo && colValue < valueMemo) {
        rank = order == 'asc' ? data.length - i : i + 1
      }
      valueMemo = colValue

      const rowIndex = order == 'asc' ? data.length - i : i
      const row = this.hot.getSourceDataAtRow(this.hot.toPhysicalRow(i))
      row['rank'] = rank

      return row
    })
    this.hot.loadData(newData)
  }

  constructor() {
    $(document).on('ready turbolinks:load', () => {
      const leaderboardContainer = $('#leaderboard-root')
      if (!leaderboardContainer.length) return

      const data = leaderboardContainer.data('leaderboardJson')
      this.originalData = cloneDeep(data)
      this.hot = new Handsontable(leaderboardContainer[0], {
        data: data,
        rowHeaders: false,
        colHeaders: [
          'Rank',
          'Team',
          'Total Points',
          'Questions Answered',
          'Average Question Score'
        ],
        columns: [
          { data: 'rank' },
          { data: 'team' },
          { data: 'totalPoints' },
          { data: 'questionsAnswered' },
          { data: 'averageQuestionScore' }
        ],
        filters: true,
        dropdownMenu: true,
        columnSorting: {
          initialConfig: {
            column: 2,
            sortOrder: 'desc'
          }
        },
        licenseKey: 'non-commercial-and-evaluation',
        afterColumnSort: this.afterColumnSort.bind(this)
      })
    })
  }
}
