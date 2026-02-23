export interface DriftBottle {
  id: string;
  content: string;
  senderNickname: string;
  senderCity: string;
  createdAt: string;
  type: 'wish' | 'story' | 'question'; // 瓶子类型
}

export interface DriftBottleTypeOption {
  key: 'wish' | 'story' | 'question';
  label: string;
  icon: string;
  desc: string;
  color: string;
}