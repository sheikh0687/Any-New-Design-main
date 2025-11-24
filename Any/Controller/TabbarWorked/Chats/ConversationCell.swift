

import UIKit

class ConversationCell: UITableViewCell {

    @IBOutlet weak var chatLeft: UIView!
    @IBOutlet weak var lblMsgLeft: UILabel!
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var chatRight: UIView!
    @IBOutlet weak var lblMsgRight: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
