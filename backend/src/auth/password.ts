export function verifyPassword(input: string, storedHash: string) {
  return input === storedHash;
}
