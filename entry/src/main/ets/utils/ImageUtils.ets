/**
 * 图像处理工具类 (压缩与 OSS 格式化)
 */
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

export class ImageUtils {

  /**
   * 格式化 OSS 图片 URL，实现缩略图和格式转换 (按需加载)
   * @param url 原始图片 URL
   * @param scene 场景: 'thumb' (列表缩略图, 300x300), 'avatar' (头像, 150x150), 'origin' (原图预览)
   */
  public static formatOssUrl(url: string, scene: 'thumb' | 'avatar' | 'origin' = 'origin'): string {
    if (!url) return '';

    // 如果不是阿里云 OSS 的默认链接，直接返回（比如 Unsplash 假数据或已经带参数的链接）
    if (!url.includes('aliyuncs.com') || url.includes('x-oss-process')) {
      return url;
    }

    let processParams = '?x-oss-process=image';

    switch (scene) {
      case 'thumb':
        // 社区列表九宫格：裁剪成 300x300 的正方形，转为 webp 极度省流
        processParams += '/resize,m_fill,w_300,h_300/format,webp';
        break;
      case 'avatar':
        // 头像：裁剪成 150x150 的正方形
        processParams += '/resize,m_fill,w_150,h_150/format,webp';
        break;
      case 'origin':
      default:
      // 全屏预览：不改变尺寸，只限制最大宽度以防万一，并转格式
        processParams += '/resize,w_1920/format,webp';
        break;
    }

    return url + processParams;
  }

  /**
   * 压缩本地图片 (用于发布前上传)
   * 规则：长边不超过 1920，JPEG 质量 80
   * @param context UIAbilityContext
   * @param sourceUri 原始图库 URI
   * @returns 压缩后在沙箱中的文件路径 (可以直接传给网络库上传)
   */
  public static async compressImage(context: common.UIAbilityContext, sourceUri: string): Promise<string> {
    try {
      // 1. 打开原始文件
      const file = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY);

      // 2. 创建图片源 (ImageSource)
      const imageSource = image.createImageSource(file.fd);
      const imageInfo = await imageSource.getImageInfo();

      // 3. 计算缩放比例 (长边不超过 1920)
      const MAX_SIDE = 1920;
      let scale = 1;
      const longestSide = Math.max(imageInfo.size.width, imageInfo.size.height);

      if (longestSide > MAX_SIDE) {
        scale = MAX_SIDE / longestSide;
      }

      const targetWidth = Math.round(imageInfo.size.width * scale);
      const targetHeight = Math.round(imageInfo.size.height * scale);

      // 4. 解码并缩放图片
      const decodingOptions: image.DecodingOptions = {
        desiredSize: { width: targetWidth, height: targetHeight }
      };
      const pixelMap = await imageSource.createPixelMap(decodingOptions);

      // 5. 压缩并打包成 JPEG
      const imagePacker = image.createImagePacker();
      const packOptions: image.PackingOption = {
        format: 'image/jpeg',
        quality: 80 // 质量设为 80，肉眼无损且体积大减
      };

      const buffer = await imagePacker.packing(pixelMap, packOptions);

      // 6. 将压缩后的 Buffer 写入沙箱缓存目录
      const compressedFileName = `compressed_${Date.now()}.jpg`;
      const compressedFilePath = `${context.cacheDir}/${compressedFileName}`;

      const destFile = fs.openSync(compressedFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(destFile.fd, buffer);
      fs.closeSync(destFile);

      // 7. 释放内存
      pixelMap.release();
      imageSource.release();
      fs.closeSync(file);

      console.info(`[ImageUtils] 图片压缩成功，保存在: ${compressedFilePath}`);
      return compressedFilePath;

    } catch (error) {
      console.error('[ImageUtils] 图片压缩失败，将返回原路径:', error);
      // 如果压缩失败，作为兜底，直接返回原图 URI
      return sourceUri;
    }
  }
}