const { test, expect } = require('@playwright/test');

test.describe('Sky Drop - Visual Regression Testing', () => {
  
  test('should display game with correct visual layout', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    await page.waitForTimeout(3000); // Allow game to fully load
    
    // Take screenshot of initial game state
    await expect(canvas).toHaveScreenshot('game-initial-load.png', {
      threshold: 0.3, // Allow some variance for dynamic content
    });
  });

  test('should display main menu correctly', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    await page.waitForTimeout(3000);
    
    // Screenshot of main menu
    await expect(canvas).toHaveScreenshot('main-menu.png', {
      threshold: 0.2,
    });
  });

  test('should show gameplay with parallax background', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(3000); // Let game start and show parallax
    
    // Move player to show different parallax positions
    await frame.keyboard.press('ArrowLeft');
    await page.waitForTimeout(500);
    await frame.keyboard.press('ArrowRight');
    await page.waitForTimeout(500);
    
    // Screenshot during gameplay
    await expect(canvas).toHaveScreenshot('gameplay-parallax.png', {
      threshold: 0.4, // Higher threshold due to dynamic content
    });
  });

  test('should display parachute deployment correctly', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Deploy parachute
    await frame.keyboard.press('Space');
    await page.waitForTimeout(1000);
    
    // Screenshot with parachute deployed
    await expect(canvas).toHaveScreenshot('parachute-deployed.png', {
      threshold: 0.3,
    });
  });

  test('should maintain visual consistency across browser resize', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Test at different viewport sizes
    const viewports = [
      { width: 1920, height: 1080, name: 'desktop-large' },
      { width: 1366, height: 768, name: 'desktop-standard' },
      { width: 768, height: 1024, name: 'tablet-portrait' },
    ];
    
    for (const viewport of viewports) {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(2000);
      
      // Take screenshot at this viewport size
      await expect(canvas).toHaveScreenshot(`viewport-${viewport.name}.png`, {
        threshold: 0.3,
      });
    }
  });

  test('should show proper visual feedback for interactions', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Test visual feedback during movement
    await frame.keyboard.down('ArrowLeft');
    await page.waitForTimeout(300);
    
    // Screenshot while moving left
    await expect(canvas).toHaveScreenshot('moving-left.png', {
      threshold: 0.4,
    });
    
    await frame.keyboard.up('ArrowLeft');
    await frame.keyboard.down('ArrowRight');
    await page.waitForTimeout(300);
    
    // Screenshot while moving right
    await expect(canvas).toHaveScreenshot('moving-right.png', {
      threshold: 0.4,
    });
    
    await frame.keyboard.up('ArrowRight');
  });

  test('should handle visual states during extended gameplay', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Simulate gameplay progression
    for (let i = 0; i < 5; i++) {
      await frame.keyboard.press('ArrowLeft');
      await page.waitForTimeout(500);
      await frame.keyboard.press('ArrowRight');
      await page.waitForTimeout(500);
    }
    
    // Screenshot after some gameplay time
    await expect(canvas).toHaveScreenshot('extended-gameplay.png', {
      threshold: 0.4,
    });
    
    // Deploy parachute and continue
    await frame.keyboard.press('Space');
    await page.waitForTimeout(2000);
    
    // Screenshot with parachute during extended play
    await expect(canvas).toHaveScreenshot('extended-with-parachute.png', {
      threshold: 0.4,
    });
  });
});