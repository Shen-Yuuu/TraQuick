import { Post, PostAuthor, PostLocation } from '../models/Post';
import { ApiPost } from '../services/ApiService';

/**
 * 统一将后端帖子结构转换为前端 Post 结构。
 */
export function mapApiPostToPost(apiPost: ApiPost): Post {
  const author: PostAuthor = {
    id: apiPost.author.id,
    nickname: apiPost.author.nickname,
    avatar: apiPost.author.avatar,
    level: apiPost.author.level,
    levelTitle: apiPost.author.levelTitle,
  };

  const post: Post = {
    id: apiPost.id,
    author: author,
    content: apiPost.content,
    images: apiPost.images,
    tags: apiPost.tags,
    likeCount: apiPost.likeCount,
    commentCount: apiPost.commentCount,
    shareCount: apiPost.shareCount,
    collectCount: apiPost.collectCount,
    isLiked: apiPost.isLiked,
    isCollected: apiPost.isCollected,
    createdAt: apiPost.createdAt,
    type: apiPost.type as 'image' | 'video',
    hotComments: [],
  };

  if (apiPost.video) {
    post.video = apiPost.video;
  }

  if (apiPost.city !== null) {
    const location: PostLocation = {
      cityId: apiPost.city.id,
      cityName: apiPost.city.name,
    };
    if (apiPost.address) {
      location.address = apiPost.address;
    }
    if (apiPost.latitude) {
      location.latitude = apiPost.latitude;
    }
    if (apiPost.longitude) {
      location.longitude = apiPost.longitude;
    }
    post.location = location;
  }

  return post;
}

/**
 * 统一深拷贝 Post，避免各页面重复维护。
 */
export function clonePost(source: Post): Post {
  const authorCopy: PostAuthor = {
    id: source.author.id,
    nickname: source.author.nickname,
    avatar: source.author.avatar,
    level: source.author.level,
    levelTitle: source.author.levelTitle,
  };

  const cloned: Post = {
    id: source.id,
    author: authorCopy,
    content: source.content,
    images: source.images.slice(),
    tags: source.tags.slice(),
    likeCount: source.likeCount,
    commentCount: source.commentCount,
    shareCount: source.shareCount,
    collectCount: source.collectCount,
    isLiked: source.isLiked,
    isCollected: source.isCollected,
    createdAt: source.createdAt,
    type: source.type,
  };

  if (source.video) {
    cloned.video = source.video;
  }

  if (source.location) {
    const locCopy: PostLocation = {
      cityId: source.location.cityId,
      cityName: source.location.cityName,
    };
    if (source.location.address) {
      locCopy.address = source.location.address;
    }
    if (source.location.latitude) {
      locCopy.latitude = source.location.latitude;
    }
    if (source.location.longitude) {
      locCopy.longitude = source.location.longitude;
    }
    cloned.location = locCopy;
  }

  return cloned;
}