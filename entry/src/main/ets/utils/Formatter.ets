/**
 * TraQuick 通用格式化工具
 * 集中管理时间、数量等格式化逻辑，避免各页面重复实现
 */

/**
 * 将 ISO 时间字符串格式化为人性化的相对时间
 * @param dateStr ISO 时间字符串，如 '2024-01-15T12:30:00Z'
 * @returns 格式化后的字符串：刚刚 / X分钟前 / X小时前 / X天前 / M月D日
 */
export function formatTime(dateStr: string): string {
  const date = new Date(dateStr);
  const now = new Date();
  const diff = now.getTime() - date.getTime();

  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);

  if (minutes < 1) return '刚刚';
  if (minutes < 60) return `${minutes}分钟前`;
  if (hours < 24) return `${hours}小时前`;
  if (days < 7) return `${days}天前`;
  if (days < 365) return `${date.getMonth() + 1}月${date.getDate()}日`;

  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
}

/**
 * 将数量格式化为简洁的显示文本
 * @param count 原始数量
 * @returns 格式化后的字符串：万(≥10000) / k(≥1000) / 原始数字
 */
export function formatCount(count: number): string {
  if (count >= 10000) {
    return `${(count / 10000).toFixed(1)}万`;
  } else if (count >= 1000) {
    return `${(count / 1000).toFixed(1)}k`;
  }
  return `${count}`;
}
