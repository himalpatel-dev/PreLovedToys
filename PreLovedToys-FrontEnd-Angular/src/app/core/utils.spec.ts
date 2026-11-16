import { formatAmount, imageUrl, isAppAsset, uploadedPath, SERVER_URL } from './utils';

describe('imageUrl', () => {
  it('keeps full URLs and data URLs as they are', () => {
    expect(imageUrl('https://picsum.photos/200')).toBe('https://picsum.photos/200');
    expect(imageUrl('data:image/png;base64,AAA')).toBe('data:image/png;base64,AAA');
  });

  it('resolves server paths and bare upload filenames against the server', () => {
    expect(imageUrl('/uploads/a.jpg')).toBe(`${SERVER_URL}/uploads/a.jpg`);
    expect(imageUrl('a.jpg')).toBe(`${SERVER_URL}/uploads/a.jpg`);
  });

  it('returns null for empty values and images bundled in the mobile app', () => {
    expect(imageUrl(null)).toBeNull();
    expect(imageUrl('')).toBeNull();
    expect(imageUrl('/assets/Board Games.png')).toBeNull();
    expect(isAppAsset('assets/x.png')).toBe(true);
  });

  it('stores uploads with a leading slash so Flutter can prefix the server URL', () => {
    expect(uploadedPath('123.jpg')).toBe('/uploads/123.jpg');
  });
});

describe('formatAmount', () => {
  it('handles BIGINT strings from Postgres and both currencies', () => {
    expect(formatAmount('1200', false)).toBe('₹1,200');
    expect(formatAmount('10', true)).toBe('10 pts');
    expect(formatAmount(null)).toBe('₹0');
  });
});
