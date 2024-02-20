import React, {Children, useState} from 'react';
import {useEffect} from 'react';
import {Dimensions, FlatList, Text, TouchableOpacity, View} from 'react-native';
import {BluetoothModule} from './bluetoothModule';
import {Peripheral} from './bluetoothModule/types';
export default function App() {
  const [refreshingPeripherals, setRefreshingPeripherals] = useState(false);
  const [peripherals, setPeripherals] = useState<Array<Peripheral>>([]);
  const [connectedPeripheral, setConnectedPeripheral] = useState<Peripheral>();
  const [onSuccessTransfer, setOnSuccessTransfer] = useState<
    | {
        peripheralId: string;
        message: string;
      }
    | undefined
  >();

  useEffect(() => {
    BluetoothModule.startScanPeripherals(scannedPeripherals => {
      setPeripherals(scannedPeripherals);
    });
  }, []);

  const handleConnectToPeripheral = (id: string) => {
    BluetoothModule.connectToPeripheral(id, peripheral => {
      setConnectedPeripheral(peripheral);
    });
  };

  const handleDisconnectToPeripheral = (id: string) => {
    BluetoothModule.disconnectToPeripheral(id, callback => {
      if (callback.disconnected) {
        setConnectedPeripheral(undefined);
      }
    });
  };

  const handleTransferDataToPeripheral = () => {
    BluetoothModule.transferData(onSuccessData =>
      setOnSuccessTransfer(onSuccessData),
    );
  };

  const onRefresh = () => {
    setRefreshingPeripherals(true);

    BluetoothModule.startScanPeripherals(scannedPeripherals => {
      setPeripherals(scannedPeripherals);
    });

    setTimeout(() => {
      setRefreshingPeripherals(false);
    }, 2000);
  };

  return (
    <View
      style={{
        paddingTop: Dimensions.get('screen').height * 0.1,
        flex: 1,
        width: Dimensions.get('screen').width,
        justifyContent: 'center',
        // alignItems: 'center',
        paddingHorizontal: 30,
      }}>
      <Text style={{color: 'white', fontSize: 24, fontWeight: '900'}}>
        Devices scanned:
      </Text>
      <FlatList
        onRefresh={onRefresh}
        data={peripherals}
        showsVerticalScrollIndicator={false}
        style={{width: '100%', marginTop: 24, marginBottom: 40}}
        keyExtractor={peripheral => Object.values(peripheral)[0].identifier}
        contentContainerStyle={{gap: 16}}
        refreshing={refreshingPeripherals}
        ListEmptyComponent={() =>
          !refreshingPeripherals && (
            <Text style={{color: 'white'}}>Any device scanned :(</Text>
          )
        }
        renderItem={({item}) => {
          const peripheral = Object.values(item)[0];
          return (
            <View
              style={{
                borderWidth: 1,
                borderColor: 'lightgrey',
                padding: 10,
                width: '100%',
                gap: 8,
                borderRadius: 8,
              }}>
              <Text style={{color: 'white', fontWeight: '700'}}>
                {peripheral.name}
              </Text>
              <Text style={{color: 'white', marginBottom: 8, fontSize: 10}}>
                {peripheral.identifier}
              </Text>
              {onSuccessTransfer?.peripheralId === peripheral.identifier && (
                <Text
                  style={{
                    color: 'green',
                    fontWeight: '700',
                    marginBottom: 8,
                    fontSize: 10,
                  }}>
                  {onSuccessTransfer.message}
                </Text>
              )}
              {connectedPeripheral?.identifier === peripheral.identifier &&
              connectedPeripheral.state === 'connected' ? (
                <>
                  {!onSuccessTransfer && (
                    <TouchableOpacity
                      style={{
                        backgroundColor: 'white',
                        padding: 16,
                        paddingHorizontal: 10,
                      }}
                      onPress={handleTransferDataToPeripheral}>
                      <Text style={{color: 'black', fontWeight: '700'}}>
                        Transferir dados
                      </Text>
                    </TouchableOpacity>
                  )}
                  <TouchableOpacity
                    style={{backgroundColor: 'red', padding: 10}}
                    // disabled
                    onPress={() =>
                      handleDisconnectToPeripheral(peripheral.identifier)
                    }>
                    <Text style={{color: 'white', fontWeight: '700'}}>
                      Desconectar
                    </Text>
                  </TouchableOpacity>
                </>
              ) : (
                <TouchableOpacity
                  style={{backgroundColor: 'green', padding: 10}}
                  onPress={() =>
                    handleConnectToPeripheral(peripheral.identifier)
                  }>
                  <Text
                    style={{
                      color: 'white',
                      fontWeight: '700',
                      textAlign: 'center',
                    }}>
                    Conectar
                  </Text>
                </TouchableOpacity>
              )}
            </View>
          );
        }}
      />
    </View>
  );
}
