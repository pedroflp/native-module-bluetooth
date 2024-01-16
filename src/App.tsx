import React, {useState} from 'react';
import {useEffect} from 'react';
import {Dimensions, FlatList, Text, TouchableOpacity, View} from 'react-native';
import {BluetoothModule} from './bluetoothModule';
import {Peripheral} from './bluetoothModule/types';
export default function App() {
  const [peripherals, setPeripherals] = useState<Array<Peripheral>>([]);
  const [connectedPeripheral, setConnectedPeripheral] = useState<Peripheral>();

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

  return (
    <View
      style={{
        paddingTop: Dimensions.get('screen').height * 0.1,
        height: Dimensions.get('screen').height,
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
      }}>
      <FlatList
        data={peripherals}
        keyExtractor={peripheral => Object.values(peripheral)[0].identifier}
        contentContainerStyle={{gap: 16}}
        renderItem={({item}) => {
          const peripheral = Object.values(item)[0];
          return (
            <View
              style={{
                borderWidth: 1,
                borderColor: 'lightgrey',
                padding: 10,
                gap: 8,
              }}>
              <Text style={{color: 'white'}}>{peripheral.name}</Text>
              <Text style={{color: 'white'}}>{peripheral.identifier}</Text>
              {connectedPeripheral?.identifier === peripheral.identifier ? (
                <TouchableOpacity
                  style={{backgroundColor: 'red', padding: 10}}
                  onPress={() =>
                    handleConnectToPeripheral(peripheral.identifier)
                  }>
                  <Text style={{color: 'white'}}>Desconectar</Text>
                </TouchableOpacity>
              ) : (
                <TouchableOpacity
                  style={{backgroundColor: 'green', padding: 10}}
                  onPress={() =>
                    handleConnectToPeripheral(peripheral.identifier)
                  }>
                  <Text style={{color: 'white'}}>Conectar</Text>
                </TouchableOpacity>
              )}
            </View>
          );
        }}
      />
    </View>
  );
}
