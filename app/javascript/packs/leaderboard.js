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

    let data = cloneDeep(this.hot.getData())

    let rank = 1
    let valueMemo = null

    if (order == 'asc') data.reverse()

    const newData = data.map((result, i) => {
      const colValue = parseFloat(result[column])

      if (valueMemo && colValue < valueMemo) rank = i + 1

      valueMemo = colValue

      const rowIndex = order == 'asc' ? data.length - 1 - i : i
      const row = this.hot.getSourceDataAtRow(this.hot.toPhysicalRow(rowIndex))
      row['rank'] = rank

      return row
    })

    if (order == 'asc') newData.reverse()

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
          'Average Question Score',
          'Ten Point Answers',
          'Ten Points Probability'
        ],
        columns: [
          { data: 'rank' },
          { data: 'team' },
          { data: 'totalPoints', type: 'numeric' },
          { data: 'questionsAnswered', type: 'numeric' },
          { data: 'averageQuestionScore', type: 'numeric' },
          { data: 'tenPointAnswers', type: 'numeric' },
          { data: 'tenPointAnswerProbablility', type: 'numeric' },

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
