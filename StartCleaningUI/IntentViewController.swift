//
//  IntentViewController.swift
//  StartCleaningUI
//
//  Created by Hack, Thomas on 08.07.21.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewControllerTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!

    func setupCell(label: String) {
        self.label.text = label
    }
}

class IntentViewController: UIViewController, INUIHostedViewControlling, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.rooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.cellForRow(at: indexPath) as? IntentViewControllerTableViewCell else {
            fatalError("Unknown cell")
        }
        cell.setupCell(label: self.rooms[indexPath.row])
        return cell
    }


    @IBOutlet weak var tableView: UITableView!

    var rooms: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        guard let intent = interaction.intent as? CleanRoomIntent else {
            completion(true, parameters, .zero)
            return
        }

        // Do configuration here, including preparing views and calculating a desired size for presentation.
        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}
