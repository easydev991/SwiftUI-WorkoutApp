//
//  FeedbackHelper.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import MessageUI

protocol IFeedbackHelper {
    func sendFeedback()
}

final class FeedbackHelper: NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        getRootViewController()?.dismiss(animated: true)
    }
}

extension FeedbackHelper: IFeedbackHelper {
    func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let picker = MFMailComposeViewController()
            picker.setSubject(Constants.Feedback.subject)
            picker.setMessageBody(
                "\(Constants.Feedback.sysVersion)\n\(Constants.Feedback.appVersion)\n\n\(Constants.Feedback.question)\n",
                isHTML: false
            )
            picker.setToRecipients([Constants.Feedback.toEmail])
            picker.mailComposeDelegate = self
            getRootViewController()?.present(picker, animated: true)
        } else {
            if let url = Constants.Feedback.completeURL(),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

private extension FeedbackHelper {
    func getRootViewController() -> UIViewController? {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
    }
}
