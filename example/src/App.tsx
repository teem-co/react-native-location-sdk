import * as React from 'react';

import { StyleSheet, View, Text, Button, Share, Alert } from 'react-native';
import {
  requestPermission,
  getPermissionStatus,
  onLocation,
  start,
  stop,
  isEnabled,
  onEnabledChanged,
  onAuthorizationChange,
} from 'react-native-location-sdk';
import RNFS from 'react-native-fs';

const logsPath = RNFS.CachesDirectoryPath + '/locations.log';
let fileExists = false;

onLocation(async (location) => {
  if (!fileExists) {
    fileExists = await RNFS.exists(logsPath);
    if (!fileExists) {
      await RNFS.writeFile(logsPath, '');
      fileExists = await RNFS.exists(logsPath);
    }
  }
  await RNFS.appendFile(logsPath, '\n' + JSON.stringify(location));
  console.log(location);
});

export default function App() {
  const [status, setStatus] = React.useState('not_determined');
  const [enabled, setEnabled] = React.useState(false);
  const onRequestPermission = React.useCallback(async () => {
    const res = await requestPermission();
    setStatus(res);
  }, []);
  const onShareLogs = React.useCallback(async () => {
    await Share.share({ url: logsPath });
  }, []);
  const onClearLogs = React.useCallback(async () => {
    Alert.alert('Clear logs?', '', [
      {
        text: 'Clear',
        style: 'destructive',
        async onPress() {
          await RNFS.writeFile(logsPath, '');
        },
      },
      { text: 'Cancel', style: 'cancel' },
    ]);
  }, []);

  React.useEffect(() => {
    getPermissionStatus().then(setStatus);
    isEnabled().then((value) => {
      setEnabled(value);
    });
    onEnabledChanged((value) => {
      setEnabled(value);
    });
    onAuthorizationChange((value) => {
      setStatus(value);
    });
  }, []);

  return (
    <View style={styles.container}>
      <Text>Permission status: {status}</Text>
      <Text>Enabled: {enabled.toString()}</Text>
      <Button title="Permission" onPress={onRequestPermission} />
      <Button title="Start" onPress={start} />
      <Button title="Stop" onPress={stop} />
      <Button title="Share logs" onPress={onShareLogs} />
      <Button title="Clear logs" onPress={onClearLogs} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
