const { test, expect } = require('@playwright/test');

test.describe('Sky Drop - Performance Testing', () => {
  
  test('should load within acceptable time limits', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    await frame.waitForSelector('canvas', { timeout: 10000 });
    
    const loadTime = Date.now() - startTime;
    
    // Game should load within 20 seconds
    expect(loadTime).toBeLessThan(20000);
    console.log(`Game loaded in ${loadTime}ms`);
  });

  test('should maintain stable memory usage', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Get initial memory usage
    const initialMetrics = await page.evaluate(() => {
      if (performance.memory) {
        return {
          used: performance.memory.usedJSHeapSize,
          total: performance.memory.totalJSHeapSize
        };
      }
      return { used: 0, total: 0 };
    });
    
    // Simulate extended gameplay
    for (let i = 0; i < 30; i++) {
      await frame.keyboard.press('ArrowLeft');
      await page.waitForTimeout(200);
      await frame.keyboard.press('ArrowRight');
      await page.waitForTimeout(200);
      if (i % 10 === 0) {
        await frame.keyboard.press('Space'); // Toggle parachute
      }
    }
    
    // Check memory after gameplay
    const finalMetrics = await page.evaluate(() => {
      if (performance.memory) {
        return {
          used: performance.memory.usedJSHeapSize,
          total: performance.memory.totalJSHeapSize
        };
      }
      return { used: 0, total: 0 };
    });
    
    if (initialMetrics.used > 0 && finalMetrics.used > 0) {
      // Memory shouldn't increase dramatically (less than 50MB growth)
      const memoryGrowth = finalMetrics.used - initialMetrics.used;
      expect(memoryGrowth).toBeLessThan(50 * 1024 * 1024); // 50MB
      console.log(`Memory growth: ${(memoryGrowth / 1024 / 1024).toFixed(2)}MB`);
    }
  });

  test('should maintain responsive frame rate', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Measure frame rate during gameplay
    const frameRateTest = await frame.evaluate(() => {
      return new Promise((resolve) => {
        let frameCount = 0;
        let startTime = performance.now();
        
        function countFrame() {
          frameCount++;
          if (performance.now() - startTime >= 2000) { // Test for 2 seconds
            const fps = frameCount / 2;
            resolve(fps);
          } else {
            requestAnimationFrame(countFrame);
          }
        }
        
        requestAnimationFrame(countFrame);
      });
    });
    
    // Should maintain at least 30fps (ideally 60fps)
    expect(frameRateTest).toBeGreaterThan(30);
    console.log(`Average FPS: ${frameRateTest.toFixed(2)}`);
  });

  test('should handle browser tab visibility changes', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Simulate tab becoming hidden
    await page.evaluate(() => {
      Object.defineProperty(document, 'hidden', { value: true, writable: true });
      document.dispatchEvent(new Event('visibilitychange'));
    });
    
    await page.waitForTimeout(1000);
    
    // Simulate tab becoming visible again
    await page.evaluate(() => {
      Object.defineProperty(document, 'hidden', { value: false, writable: true });
      document.dispatchEvent(new Event('visibilitychange'));
    });
    
    await page.waitForTimeout(1000);
    
    // Game should still be responsive
    await frame.keyboard.press('ArrowLeft');
    await expect(canvas).toBeVisible();
  });

  test('should handle window resize gracefully', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Get initial canvas size
    const initialBox = await canvas.boundingBox();
    
    // Resize the viewport
    await page.setViewportSize({ width: 800, height: 1200 });
    await page.waitForTimeout(1000);
    
    // Check if canvas is still visible and properly sized
    const resizedBox = await canvas.boundingBox();
    expect(resizedBox.width).toBeGreaterThan(200);
    expect(resizedBox.height).toBeGreaterThan(300);
    
    // Game should still be responsive
    await canvas.click({ position: { x: 180, y: 350 } });
    await frame.keyboard.press('ArrowLeft');
    await expect(canvas).toBeVisible();
  });
});