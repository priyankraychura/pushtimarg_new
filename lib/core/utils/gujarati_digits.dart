/// "12" → "૧૨", for stanza and prasang markers.
String gujaratiDigits(int n) {
  const digits = ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'];
  return n.toString().split('').map((d) => digits[int.parse(d)]).join();
}
