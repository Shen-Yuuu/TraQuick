export interface TimeCapsule {
  id: string;
  content: string;
  images: string[];
  targetDate: string;      // 解封日期 (ISO 字符串)
  createdAt: string;       // 创建日期
  location: CapsuleLocation;
  status: 'locked' | 'unlocked';
}

export interface CapsuleLocation {
  cityName: string;
  address: string;
}