//
//  TriggerCommandEditViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/27/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

protocol TriggerCommandEditViewControllerDelegate {
    func saveCommands(schemaName: String,
                      schemaVersion: Int,
                      actions: [Dictionary<String, AnyObject>],
                      targetID: String?,
                      title: String?,
                      commandDescription: String?,
                      metadata: Dictionary<String, AnyObject>?)
}

class TriggerCommandEditViewController: CommandEditViewController {

    var delegate: TriggerCommandEditViewControllerDelegate?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        var targetIdSection = SectionStruct(headerTitle: "Target thing ID",
                                            items: [])
        var titleSection = SectionStruct(headerTitle: "Title", items: [])
        var descriptionSection = SectionStruct(headerTitle: "Description",
                                               items: [])
        var metadataSection = SectionStruct(headerTitle: "Meta data",
                                            items: [])

        if let command = self.commandStruct {
            if let targetID = command.targetID {
                targetIdSection.items.append(targetID)
            }
            if let title = command.title {
                titleSection.items.append(title)
            }
            if let description = command.commandDescription {
                descriptionSection.items.append(description)
            }
            if let metadata = command.metadata {
                if let data = try? NSJSONSerialization.dataWithJSONObject(
                     metadata, options: .PrettyPrinted) {
                    metadataSection.items.append(
                      String(data:data,
                             encoding:NSUTF8StringEncoding)!)
                }
            }
        }

        sections += [targetIdSection, titleSection, descriptionSection,
                     metadataSection]
    }

    override func tableView(
      tableView: UITableView,
      cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if sections[indexPath.section].headerTitle == "Target thing ID" {
            let cell = tableView.dequeueReusableCellWithIdentifier(
              "TargetIDCell",
              forIndexPath: indexPath)
            if let items = sections[indexPath.section].items
              where !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(202) as! UITextField).text = value
            }
            return cell
        } else if sections[indexPath.section].headerTitle == "Title" {
            let cell = tableView.dequeueReusableCellWithIdentifier(
              "CommandTitleCell",
              forIndexPath: indexPath)
            if let items = sections[indexPath.section].items
              where !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(203) as! UITextField).text = value
            }
            return cell
        } else if sections[indexPath.section].headerTitle == "Description" {
            let cell = tableView.dequeueReusableCellWithIdentifier(
              "CommandDescriptionCell",
              forIndexPath: indexPath)

            if let items = sections[indexPath.section].items
              where !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(204) as! UITextView).text = value
            }
            return cell
        } else if sections[indexPath.section].headerTitle == "Meta data" {
            let cell = tableView.dequeueReusableCellWithIdentifier(
              "CommandMetadataCell", forIndexPath: indexPath)
            if let items = sections[indexPath.section].items
              where !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(205) as! UITextView).text = value
            }
            return cell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(
      tableView: UITableView,
      heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if sections[indexPath.section].headerTitle == "Description" {
            return 130
        } else if sections[indexPath.section].headerTitle == "Meta data" {
            return 130
        } else {
            return super.tableView(tableView,
                                   heightForRowAtIndexPath: indexPath)
        }
    }

    @IBAction func tapSaveCommand(sender: AnyObject) {
        // generate actions array
        var actions = [Dictionary<String, AnyObject>]()
        if let actionsItems = sections[2].items {
            for actionItem in actionsItems {
                if let actionCellData = actionItem as? ActionStruct {
                    // action should be like: ["actionName": ["requiredStatus": value] ], where value can be Bool, Int or Double
                    actions.append(actionCellData.getActionDict())
                }
            }
        }
        // the defaultd schema and schemaVersion from predefined schem dict
        let schema: String? = (self.view.viewWithTag(200) as? UITextField)?.text
        let schemaVersion: Int?
        if let schemaVersionTextFiled = self.view.viewWithTag(201) as? UITextField {
            schemaVersion = Int(schemaVersionTextFiled.text!)!
        } else {
            schemaVersion = nil
        }
        let targetID: String?
        if let text = (self.view.viewWithTag(202) as? UITextField)?.text
          where !text.isEmpty {
            targetID = text
        } else {
            targetID = nil
        }
        let title: String?
        if let text = (self.view.viewWithTag(203) as? UITextField)?.text
          where !text.isEmpty {
            title = text
        } else {
            title = nil
        }
        let description: String?
        if let text = (self.view.viewWithTag(204) as? UITextView)?.text
          where !text.isEmpty {
            description = text
        } else {
            description = nil
        }
        let metadata: Dictionary<String, AnyObject>?
        if let text = (self.view.viewWithTag(205) as? UITextView)?.text {
            metadata = try? NSJSONSerialization.JSONObjectWithData(
              text.dataUsingEncoding(NSUTF8StringEncoding)!,
              options: .MutableContainers) as! Dictionary<String, AnyObject>
        } else {
            metadata = nil
        }

        if self.delegate != nil {
            delegate?.saveCommands(schema!,
                                   schemaVersion: schemaVersion!,
                                   actions: actions,
                                   targetID: targetID,
                                   title: title,
                                   commandDescription: description,
                                   metadata: metadata)
        }

        self.navigationController?.popViewControllerAnimated(true)
    }

}
