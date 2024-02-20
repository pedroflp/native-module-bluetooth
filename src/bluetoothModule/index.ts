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
      callback(event);
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
      callback(event);
    });

    return sub;
  }

  export function disconnectToPeripheral(
    peripheralId: string,
    callback: (event: {peripheralId: string; disconnected: boolean}) => void,
  ) {
    Bluetooth.disconnectPeripheral(peripheralId);

    const sub = eventEmitter.addListener('disconnectedPeripheral', event => {
      callback(event);
    });

    return sub;
  }

  export function transferData(
    callback: (data: {peripheralId: string; message: string}) => void,
  ) {
    Bluetooth.transferData();

    const sub = eventEmitter.addListener('transferData', event => {
      callback(event);
    });

    return sub;
  }
}
