import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";


message ChangeConfig {
    bid: Int as int128;
    minPrise: Int as int128;
    maxPrise: Int as int128;
}

const MinForStorage: Int = ton("0.02");

contract Lottery with OwnableTransferable, Stoppable, Resumable {
    owner: Address;
    stopped: Bool;
    bid: Int as int128;
    minPrise: Int as int128;
    maxPrise: Int as int128;

    init(bid: Int, minPrise: Int, maxPrise: Int) {
        self.owner = sender();
        self.stopped = false;
        self.bid = bid;
        self.minPrise = minPrise;
        self.maxPrise = maxPrise;
    }
    receive() {}

    receive("stop") {
        self.requireOwner();
        self.stopped=true;
    }
    receive("resume") {
        self.requireOwner();
        self.stopped=false;
    }
    receive("bid") {
        self.requireNotStopped();
        if(context().value == self.bid){
            let seed: Int = getSeed();
            setSeed(seed);
            let prize: Int = random(self.minPrise, self.maxPrise);
            if (myBalance() < prize) {
                send(SendParameters{
                    to: sender(),
                    value: 0,
                    mode: SendRemainingValue | SendIgnoreErrors,
                    body: "insuficient funds".asComment()
                });
                }
                else{
                    send(SendParameters{
                        to: sender(),
                        value: prize,
                        mode: SendIgnoreErrors,
                        body:"🎰".asComment()
                    });
                }
            }
            else{
                let str1: String = "bid must be";
                let str2: String = self.bid.toCoinsString();
                let str3: String = " ton";
                let sb: StringBuilder = beginString();
                sb.append(str1);
                sb.append(str2);
                sb.append(str3);
                let str4: String = sb.toString();

                send(SendParameters{
                    to: sender(),
                    value: 0,
                    mode: SendRemainingValue | SendIgnoreErrors,
                    body: str4.asComment()
                });
            }
        }
        receive("withdraw") {
            self.requireOwner();
            send(SendParameters{
                to: sender(),
                value: myBalance() - context().value - MinForStorage,
                mode: SendIgnoreErrors | SendRemainingValue,
                bounce: true
            });
        }
        receive(msg: ChangeConfig) {
            self.requireOwner();
            self.bid = msg.bid;
            self.minPrise = msg.minPrise;
            self.maxPrise = msg.maxPrise;
            send(SendParameters{
                to: sender(),
                value: ton("0.0015"),
                mode: SendIgnoreErrors,
                body: "config changed".asComment()
            });
        }
    get fun get_bid(): Int {
        return self.bid;
    }

    get fun get_min_prize(): Int {
        return self.minPrise;
    }

    get fun get_max_prize(): Int {
        return self.maxPrise;
    }
    }
