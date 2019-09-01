//
//  main.swift
//  Async
//
//  Created by Leandro Costa on 30/08/2019.
//

import Foundation
import SlackKit
import Configuration

class HackathonBot {
    
    let bot: SlackKit
    let restManager = RestManager()
    
    init(token: String) {
        bot = SlackKit()
        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)
        bot.notificationForEvent(.message) { [weak self] (event, client) in
            guard
                let message = event.message,
                let id = client?.client?.authenticatedUser?.id,
                message.text?.contains(id) == true
                else {
                    return
            }
            self?.handleMessage(message)
        }
    }
    
    init(clientID: String, clientSecret: String) {
        bot = SlackKit()
        let oauthConfig = OAuthConfig(clientID: clientID, clientSecret: clientSecret)
        bot.addServer(oauth: oauthConfig)
        bot.notificationForEvent(.message) { [weak self] (event, client) in
            guard
                let message = event.message,
                let id = client?.client?.authenticatedUser?.id,
                message.text?.contains(id) == true
                else {
                    return
            }
            self?.handleMessage(message)
        }
    }
    
    enum Command : String {
        case balance
        case transfer
        case illegal
        case test
        
        enum CustomError: Error {
            case illegalArgument
        }
        
        static func getFrom(stringCommand: String) -> Command{
            switch stringCommand {
                case "balance":
                    return balance
                case "transferir":
                    return transfer
                case "test":
                    return test
                default:
                    return illegal
            }
        }
        
        func execute(_ restManager: RestManager, _ textParsed: [String], _ message: Message, _ bot: SlackKit) {
            switch self {
                case .balance:
                    bot.webAPI?.sendMessage(channel: message.channel!, text: "Checking your balance... :bank:",
                        iconEmoji: "robot_face", success: nil, failure: nil)
                    TendermintRequester.getWoloxCoins(from: message.user!, restManager: restManager)
                case .transfer:
                    let quantity = textParsed[2]
                    let recipient = textParsed[3]
                    // TODO: Check for illegalArgumentException
                    bot.webAPI?.sendMessage(channel: message.channel!, text: "Transferring \(quantity) "
                        + ":money_with_wings: :money_with_wings: :money_with_wings:",
                                            iconEmoji: "robot_face", success: nil, failure: nil)
                    TendermintRequester.transfer(woloxCoins: Int(quantity) ?? 0, to: recipient,
                                                 origin: message.user!, restManager: restManager)
                case .test:
                    bot.webAPI?.addReactionToMessage(name: "thumbsup", channel: message.channel!,
                                                     timestamp: message.ts!, success: nil, failure: nil)
                    bot.webAPI?.sendMessage(channel: message.channel!, text: "I'm listening :smiley:",
                                            iconEmoji: "robot_face", success: nil, failure: nil)
                default:
                    print("Soy ilegal")
            }
        }
    }
    
    private func handleMessage(_ message: Message) {
        print(message.user!.lowercased())
        print(message.text!.lowercased())
        if let text = message.text?.lowercased() {
            let textParsed = text.components(separatedBy: " ")
            let command = Command.getFrom(stringCommand: textParsed[1].lowercased())
            command.execute(restManager, textParsed, message, bot)
        }
    }
}

// configuration.json should have an APIKEY with its value
let configurationManager = ConfigurationManager()
    .load(file: "secrets/configuration.json", relativeFrom: .pwd)
let apikey = (configurationManager["APIKEY"] as? String)

// Using API KEY to connect to slack
let slackbot = HackathonBot(token: apikey!)

RunLoop.main.run()
