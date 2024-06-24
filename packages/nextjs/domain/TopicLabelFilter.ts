const suffixes = ["Wikipedia"];
function removeSuffix(input: string, prefixes: string[]): string {
  let result = input;
  prefixes.forEach(prefix => {
    const pattern = new RegExp(`- ${prefix}`, "gi");
    result = result.replace(pattern, "");
    result = result.trim(); // remove any trailing spaces
  });
  return result;
}

export function removeSuffixes(input: string): string {
  return removeSuffix(input, suffixes);
}
