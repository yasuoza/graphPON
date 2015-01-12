import UIKit

class HddServiceListTableViewController: UITableViewController {

    private var services: [String] = []
    var selectedService: String = ""
    var mode: BaseLineChartViewController.Mode = .Summary
    weak var delegate: HddServiceListTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        switch self.mode {
        case .Summary:
            self.services = PacketInfoManager.sharedManager.hddServiceCodes()
        case .Daily:
            self.services = PacketInfoManager.sharedManager.hdoServiceCodes()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IBActions

    @IBAction func closeViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.mode == .Daily {
            return PacketInfoManager.sharedManager.hddServiceCodes().count ?? 1
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.mode == .Daily {
            return PacketInfoManager.sharedManager.hddServiceCodes()[section]
        }
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HddServiceCell", forIndexPath: indexPath) as UITableViewCell

        let serviceCode = self.services[indexPath.row]

        cell.textLabel?.text = serviceCode

        if self.selectedService == serviceCode {
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
        delegate?.serviceDidSelectedSection(indexPath.section, row: indexPath.row)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
