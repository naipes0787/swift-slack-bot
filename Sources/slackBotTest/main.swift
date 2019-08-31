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
        
        enum CustomError: Error {
            case illegalArgument
        }
        
        static func getFrom(stringCommand: String) -> Command{
            switch stringCommand {
                case "balance":
                    return balance
                case "transferir":
                    return transfer
                default:
                    return illegal
            }
        }
        
        func execute(restManager: RestManager, textParsed: [String], user: String) {
            switch self {
                case .balance:
                    TendermintRequester.getWoloxCoins(from: user, restManager: restManager)
                case .transfer:
                    let quantity = textParsed[2]
                    let recipient = textParsed[3]
                    // TODO: Check for illegalArgumentException
                    TendermintRequester.transfer(woloxCoins: Int(quantity) ?? 0, to: recipient,
                                                 origin: user, restManager: restManager)
                default:
                    print("Soy ilegal")
            }
        }
    }
    
    // MARK: Bot logic
    private func handleMessage(_ message: Message) {
        print(message.user!.lowercased())
        print(message.text!.lowercased())
        if let text = message.text?.lowercased(), let timestamp = message.ts, let channel = message.channel {
            let textParsed = text.components(separatedBy: " ")
            let command = Command.getFrom(stringCommand: textParsed[1].lowercased())
            command.execute(restManager: restManager, textParsed: textParsed, user: message.user!)
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
