import {
  EmitterSubscription,
  NativeEventEmitter,
  NativeModules,
} from 'react-native';
import {Peripheral} from './types';

const {Bluetooth} = NativeModules;

export namespace BluetoothModule {
  const eventEmitter = new NativeEventEmitter(Bluetooth);
  export function startScanPeripherals(
    callback: (peripherals: Array<Peripheral>) => void,
  ): EmitterSubscription | undefined {
    Bluetooth.startScan();

    const sub = eventEmitter.addListener('peripherals', event => {
      callback(event as Array<Peripheral>);
    });

    return sub;
  }

  export function stopScanPeripherals(eventSub?: EmitterSubscription) {
    Bluetooth.stopScan();
    if (eventSub != null) {
      eventSub.remove();
    }
  }

  export function connectToPeripheral(
    peripheralId: string,
    callback: (peripheral: any) => void,
  ) {
    Bluetooth.connectPeripheral(peripheralId);

    const sub = eventEmitter.addListener('connectedPeripheral', event => {
      callback(event as any);
    });

    return sub;
  }
}
