import UIKit

class DisplayPacketLogsSelectTableViewController: UITableViewController {

    var delegate: DisplayPacketLogsSelectTableViewControllerDelegate?
    var selectedFilteringSegment: BaseChartViewController.ChartDataFilteringSegment?


    // MARK: - IBActions

    @IBAction func closeViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FilterPacketLogsSelectCell", forIndexPath: indexPath) as UITableViewCell

        let chartDataSegment = BaseChartViewController.ChartDataFilteringSegment(rawValue: indexPath.row)

        cell.textLabel?.text = chartDataSegment?.text() ?? ""

        if indexPath.row == self.selectedFilteringSegment?.rawValue {
            cell.selected = true
            cell.accessoryType = .Checkmark
            cell.textLabel?.textColor = GlobalTintColor
        } else {
            cell.selected = false
            cell.accessoryType = .None
            cell.textLabel?.textColor = UIColor.blackColor()
        }


        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.displayPacketLogSegmentDidSelected(indexPath.row)
    }

}
