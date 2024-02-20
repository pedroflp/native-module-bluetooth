export type Peripheral = {
  [key: string]: {
    name: string;
    identifier: string;
    state: 'connected' | 'connecting';
  };
};
