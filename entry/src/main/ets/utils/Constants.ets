
/**
 * TraQuick 设计规范常量
 * 统一管理颜色、字体、间距等设计Token
 */

// ==================== 类型定义 ====================

interface ColorConfig {
  primary: string;
  primaryLight: string;
  primaryLighter: string;
  primaryLightest: string;
  primaryDark: string;
  bgPrimary: string;
  bgSecondary: string;
  bgTertiary: string;
  textPrimary: string;
  textSecondary: string;
  textTertiary: string;
  textQuaternary: string;
  textWhite: string;
  border: string;
  borderLight: string;
  divider: string;
  success: string;
  warning: string;
  error: string;
  info: string;
  gold: string;
  orange: string;
  purple: string;
  overlay: string;
  overlayLight: string;
  tabActive: string;
  tabInactive: string;
  tabBarBg: string;
}

interface FontSizeConfig {
  h1: number;
  h2: number;
  h3: number;
  h4: number;
  h5: number;
  bodyLarge: number;
  body: number;
  bodySmall: number;
  caption: number;
  small: number;
  mini: number;
  tiny: number;
}

interface FontWeightConfig {
  regular: number;
  medium: number;
  semibold: number;
  bold: number;
}

interface SpacingConfig {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
  xxl: number;
  xxxl: number;
  pagePadding: number;
  pageMargin: number;
  cardPadding: number;
  cardMargin: number;
  itemGap: number;
  sectionGap: number;
}

interface RadiusConfig {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
  xxl: number;
  full: number;
  button: number;
  input: number;
  card: number;
  modal: number;
  avatar: number;
  tag: number;
}

interface ShadowConfig {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

interface ShadowsConfig {
  sm: ShadowConfig;
  md: ShadowConfig;
  lg: ShadowConfig;
  card: ShadowConfig;
}

interface DurationConfig {
  fast: number;
  normal: number;
  slow: number;
}

interface TabBarConfigType {
  height: number;
  iconSize: number;
  iconSizeActive: number;
  publishButtonSize: number;
}

interface SizesConfig {
  avatarXs: number;
  avatarSm: number;
  avatarMd: number;
  avatarLg: number;
  avatarXl: number;
  iconXs: number;
  iconSm: number;
  iconMd: number;
  iconLg: number;
  buttonSm: number;
  buttonMd: number;
  buttonLg: number;
  inputHeight: number;
  statusBarHeight: number;
  bottomSafeArea: number;
}

interface ZIndexConfig {
  base: number;
  dropdown: number;
  sticky: number;
  fixed: number;
  modal: number;
  popover: number;
  tooltip: number;
  toast: number;
}

interface UserLevelConfig {
  name: string;
  minCities: number;
  color: string;
}

type UserLevelsMap = UserLevelConfig[];

// ==================== 颜色系统 ====================

export const Colors: ColorConfig = {
  primary: '#38BDF8',
  primaryLight: '#7DD3FC',
  primaryLighter: '#BAE6FD',
  primaryLightest: '#E0F2FE',
  primaryDark: '#0EA5E9',
  bgPrimary: '#FFFFFF',
  bgSecondary: '#F8FAFC',
  bgTertiary: '#F1F5F9',
  textPrimary: '#0F172A',
  textSecondary: '#475569',
  textTertiary: '#64748B',
  textQuaternary: '#94A3B8',
  textWhite: '#FFFFFF',
  border: '#E2E8F0',
  borderLight: '#F1F5F9',
  divider: '#F1F5F9',
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  info: '#38BDF8',
  gold: '#FBBF24',
  orange: '#F97316',
  purple: '#8B5CF6',
  overlay: 'rgba(0, 0, 0, 0.5)',
  overlayLight: 'rgba(0, 0, 0, 0.3)',
  tabActive: '#0EA5E9',
  tabInactive: '#94A3B8',
  tabBarBg: '#FFFFFF',
}

// ==================== 字体系统 ====================

export const FontSizes: FontSizeConfig = {
  h1: 28,
  h2: 24,
  h3: 20,
  h4: 18,
  h5: 16,
  bodyLarge: 16,
  body: 15,
  bodySmall: 14,
  caption: 13,
  small: 12,
  mini: 11,
  tiny: 10,
}
export const FontWeights: FontWeightConfig = {
  regular: FontWeight.Regular,    // 400
  medium: FontWeight.Medium,      // 500
  semibold: 600,                  // 600
  bold: FontWeight.Bold,          // 700
}

// ==================== 间距系统 ====================

export const Spacing: SpacingConfig = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  pagePadding: 16,
  pageMargin: 16,
  cardPadding: 16,
  cardMargin: 12,
  itemGap: 12,
  sectionGap: 24,
}

// ==================== 圆角系统 ====================

export const Radius: RadiusConfig = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  full: 9999,
  button: 12,
  input: 12,
  card: 16,
  modal: 20,
  avatar: 9999,
  tag: 8,
}

// ==================== 阴影系统 ====================

export const Shadows: ShadowsConfig = {
  sm: {
    radius: 4,
    color: 'rgba(0, 0, 0, 0.05)',
    offsetX: 0,
    offsetY: 2,
  },
  md: {
    radius: 8,
    color: 'rgba(0, 0, 0, 0.08)',
    offsetX: 0,
    offsetY: 4,
  },
  lg: {
    radius: 16,
    color: 'rgba(0, 0, 0, 0.1)',
    offsetX: 0,
    offsetY: 8,
  },
  card: {
    radius: 12,
    color: 'rgba(0, 0, 0, 0.05)',
    offsetX: 0,
    offsetY: 2,
  },
}

// ==================== 动画时长 ====================

export const Duration: DurationConfig = {
  fast: 150,
  normal: 300,
  slow: 500,
}

// ==================== 底部导航配置 ====================

export const TabBarConfig: TabBarConfigType = {
  height: 56,
  iconSize: 24,
  iconSizeActive: 26,
  publishButtonSize: 48,
}

// ==================== 常用尺寸 ====================

export const Sizes: SizesConfig = {
  avatarXs: 24,
  avatarSm: 32,
  avatarMd: 40,
  avatarLg: 56,
  avatarXl: 80,
  iconXs: 16,
  iconSm: 20,
  iconMd: 24,
  iconLg: 32,
  buttonSm: 32,
  buttonMd: 44,
  buttonLg: 52,
  inputHeight: 48,
  statusBarHeight: 44,
  bottomSafeArea: 34,
}

// ==================== 层级系统 ====================

export const ZIndex: ZIndexConfig = {
  base: 0,
  dropdown: 10,
  sticky: 20,
  fixed: 30,
  modal: 40,
  popover: 50,
  tooltip: 60,
  toast: 70,
}

// ==================== 用户等级配置 ====================

export const UserLevels: UserLevelsMap = [
  { name: '迷雾行者', minCities: 0, color: '#94A3B8' },
  { name: '城市猎人', minCities: 5, color: '#10B981' },
  { name: '洲际探险家', minCities: 10, color: '#38BDF8' },
  { name: '环球领航员', minCities: 20, color: '#8B5CF6' },
  { name: '星耀漫游者', minCities: 50, color: '#F59E0B' },
]
