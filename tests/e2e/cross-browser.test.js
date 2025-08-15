const { test, expect } = require('@playwright/test');

test.describe('Sky Drop - Cross-Browser Compatibility', () => {
  
  test('should work consistently across Chromium', async ({ page, browserName }) => {
    test.skip(browserName !== 'chromium', 'This test is for Chromium only');
    
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Test WebGL support
    const webglSupport = await frame.evaluate(() => {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      return !!gl;
    });
    
    expect(webglSupport).toBe(true);
    
    // Test game functionality
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    await frame.keyboard.press('ArrowLeft');
    await frame.keyboard.press('Space');
    
    await expect(canvas).toBeVisible();
  });

  test('should work consistently across Firefox', async ({ page, browserName }) => {
    test.skip(browserName !== 'firefox', 'This test is for Firefox only');
    
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Test WebGL support
    const webglSupport = await frame.evaluate(() => {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      return !!gl;
    });
    
    expect(webglSupport).toBe(true);
    
    // Test game functionality
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    await frame.keyboard.press('ArrowLeft');
    await frame.keyboard.press('Space');
    
    await expect(canvas).toBeVisible();
  });

  test('should work consistently across WebKit/Safari', async ({ page, browserName }) => {
    test.skip(browserName !== 'webkit', 'This test is for WebKit only');
    
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Test WebGL support
    const webglSupport = await frame.evaluate(() => {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      return !!gl;
    });
    
    expect(webglSupport).toBe(true);
    
    // Test game functionality
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(3000); // WebKit might need more time
    
    await frame.keyboard.press('ArrowLeft');
    await frame.keyboard.press('Space');
    
    await expect(canvas).toBeVisible();
  });

  test('should handle touch events on mobile devices', async ({ page, browserName }) => {
    test.skip(browserName !== 'mobile-chrome' && browserName !== 'mobile-safari', 'Mobile test only');
    
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Test touch support
    const touchSupport = await frame.evaluate(() => {
      return 'ontouchstart' in window;
    });
    
    expect(touchSupport).toBe(true);
    
    // Test touch interactions
    await canvas.tap({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Simulate touch movements (swipe left/right)
    await canvas.tap({ position: { x: 100, y: 200 } }); // Left side
    await page.waitForTimeout(500);
    await canvas.tap({ position: { x: 260, y: 200 } }); // Right side
    
    await expect(canvas).toBeVisible();
  });

  test('should maintain performance across browsers', async ({ page, browserName }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    const startTime = Date.now();
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Test responsiveness across browsers
    const responseTest = await frame.evaluate(() => {
      return new Promise((resolve) => {
        let startTime = performance.now();
        let completed = false;
        
        function testFrame() {
          if (!completed && performance.now() - startTime >= 1000) {
            completed = true;
            resolve(performance.now() - startTime);
          } else if (!completed) {
            requestAnimationFrame(testFrame);
          }
        }
        
        requestAnimationFrame(testFrame);
      });
    });
    
    // Should complete animation frame test within reasonable time
    expect(responseTest).toBeLessThan(1500);
    console.log(`${browserName} response time: ${responseTest.toFixed(2)}ms`);
  });

  test('should handle different viewport orientations', async ({ page, browserName }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Test portrait orientation (Sky Drop's preferred orientation)
    await page.setViewportSize({ width: 400, height: 800 });
    await page.waitForTimeout(1000);
    
    let boundingBox = await canvas.boundingBox();
    expect(boundingBox.height).toBeGreaterThan(boundingBox.width);
    
    // Test landscape orientation
    await page.setViewportSize({ width: 800, height: 400 });
    await page.waitForTimeout(1000);
    
    // Game should still be playable
    await canvas.click({ position: { x: 180, y: 200 } });
    await expect(canvas).toBeVisible();
  });

  test('should support different input methods across browsers', async ({ page, browserName }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Test keyboard events
    await frame.keyboard.press('ArrowLeft');
    await frame.keyboard.press('ArrowRight');
    await frame.keyboard.press('Space');
    await frame.keyboard.press('KeyA');
    await frame.keyboard.press('KeyD');
    
    // Test key combinations
    await frame.keyboard.down('ArrowLeft');
    await frame.keyboard.press('Space');
    await frame.keyboard.up('ArrowLeft');
    
    await expect(canvas).toBeVisible();
    
    // Test reset functionality
    await frame.keyboard.press('KeyR');
    await page.waitForTimeout(1000);
    await expect(canvas).toBeVisible();
  });
});