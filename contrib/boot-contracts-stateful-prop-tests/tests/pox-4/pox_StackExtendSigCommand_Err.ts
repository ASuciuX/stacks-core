import { Pox4SignatureTopic, poxAddressToTuple } from "@stacks/stacking";
import { logCommand, PoxCommand, Real, Stub, Wallet } from "./pox_CommandModel";
import { currentCycle } from "./pox_Commands";
import { Cl } from "@stacks/transactions";
import { expect } from "vitest";

type CheckFunc = (
  this: StackExtendSigCommand_Err,
  model: Readonly<Stub>,
) => boolean;

export class StackExtendSigCommand_Err implements PoxCommand {
  readonly wallet: Wallet;
  readonly extendCount: number;
  readonly authId: number;
  readonly currentCycle: number;
  readonly checkFunc: CheckFunc;
  readonly errorCode: number;

  /**
   * Constructs a `StackExtendSigCommand` to lock uSTX for stacking.
   *
   * This command calls `stack-extend` using a `signature`.
   *
   * @param wallet - Represents the Stacker's wallet.
   * @param extendCount - Represents the cycles to extend the stack with.
   * @param authId - Unique auth-id for the authorization.
   * @param currentCycle - Represents the current PoX reward cycle.
   * @param checkFunc - A function to check constraints for running this command.
   * @param errorCode - The expected error code when running this command.
   */
  constructor(
    wallet: Wallet,
    extendCount: number,
    authId: number,
    currentCycle: number,
    checkFunc: CheckFunc,
    errorCode: number,
  ) {
    this.wallet = wallet;
    this.extendCount = extendCount;
    this.authId = authId;
    this.currentCycle = currentCycle;
    this.checkFunc = checkFunc;
    this.errorCode = errorCode;
  }

  check = (model: Readonly<Stub>): boolean => this.checkFunc.call(this, model);

  run(model: Stub, real: Real): void {
    const currentRewCycle = currentCycle(real.network);

    const stacker = model.stackers.get(this.wallet.stxAddress)!;

    const signerSig = this.wallet.stackingClient.signPoxSignature({
      // The signer key being authorized.
      signerPrivateKey: this.wallet.signerPrvKey,
      // The reward cycle for which the authorization is valid.
      // For `stack-stx` and `stack-extend`, this refers to the reward cycle
      // where the transaction is confirmed. For `stack-aggregation-commit`,
      // this refers to the reward cycle argument in that function.
      rewardCycle: currentRewCycle,
      // For `stack-stx`, this refers to `lock-period`. For `stack-extend`,
      // this refers to `extend-count`. For `stack-aggregation-commit`, this is
      // `u1`.
      period: this.extendCount,
      // A string representing the function where this authorization is valid.
      // Either `stack-stx`, `stack-extend`, `stack-increase` or `agg-commit`.
      topic: Pox4SignatureTopic.StackExtend,
      // The PoX address that can be used with this signer key.
      poxAddress: this.wallet.btcAddress,
      // The unique auth-id for this authorization.
      authId: this.authId,
      // The maximum amount of uSTX that can be used (per tx) with this signer
      // key.
      maxAmount: stacker.amountLocked,
    });

    const stackExtend = real.network.callPublicFn(
      "ST000000000000000000002AMW42H.pox-4",
      "stack-extend",
      [
        // (extend-count uint)
        Cl.uint(this.extendCount),
        // (pox-addr { version: (buff 1), hashbytes: (buff 32) })
        poxAddressToTuple(this.wallet.btcAddress),
        // (signer-sig (optional (buff 65)))
        Cl.some(Cl.bufferFromHex(signerSig)),
        // (signer-key (buff 33))
        Cl.bufferFromHex(this.wallet.signerPubKey),
        // (max-amount uint)
        Cl.uint(stacker.amountLocked),
        // (auth-id uint)
        Cl.uint(this.authId),
      ],
      this.wallet.stxAddress,
    );

    expect(stackExtend.result).toBeErr(Cl.int(this.errorCode));

    // Log to console for debugging purposes. This is not necessary for the
    // test to pass but it is useful for debugging and eyeballing the test.
    logCommand(
      `₿ ${model.burnBlockHeight}`,
      `✗ ${this.wallet.label}`,
      "stack-extend-sig",
      "extend-count",
      this.extendCount.toString(),
    );

    // Refresh the model's state if the network gets to the next reward cycle.
    model.refreshStateForNextRewardCycle(real);
  }

  toString() {
    // fast-check will call toString() in case of errors, e.g. property failed.
    // It will then make a minimal counterexample, a process called 'shrinking'
    // https://github.com/dubzzz/fast-check/issues/2864#issuecomment-1098002642
    return `${this.wallet.label} stack-extend sig extend-count ${this.extendCount}`;
  }
}
