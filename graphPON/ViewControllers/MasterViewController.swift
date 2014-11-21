import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: AreaChartViewController? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAreaChart" {
            let controller = (segue.destinationViewController as UINavigationController).topViewController as AreaChartViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "showBarChart" {
            let controller = segue.destinationViewController as BarChartViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MasterViewTableCell", forIndexPath: indexPath) as MasterViewTableCell

        var mode: MasterViewTableCell.Mode = MasterViewTableCell.Mode.LineChart
        switch indexPath.row {
        case 1:
            mode = MasterViewTableCell.Mode.BarChar
        case 2:
            mode = MasterViewTableCell.Mode.AreaChart
        default:
            break
        }
        cell.mode = mode
        cell.textLabel?.text = cell.mode.textLabelText()
        cell.detailTextLabel?.text = cell.mode.detailLabelText()
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 1:
            performSegueWithIdentifier("showBarChart", sender: self)
        default:
            performSegueWithIdentifier("showAreaChart", sender: self)
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

}

