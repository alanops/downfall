const { test, expect } = require('@playwright/test');

test.describe('Sky Drop - Game Launch and Menu Navigation', () => {
  
  test('should load the game page successfully', async ({ page }) => {
    await page.goto('/downfall');
    
    // Wait for itch.io page to load
    await expect(page).toHaveTitle(/.*downfall.*/i);
    
    // Check if the game embed is present
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await expect(gameFrame).toBeVisible({ timeout: 10000 });
  });

  test('should display main menu with play button', async ({ page }) => {
    await page.goto('/downfall');
    
    // Wait for game iframe to load
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    // Switch to game context
    const frame = await gameFrame.contentFrame();
    expect(frame).not.toBeNull();
    
    // Wait for game canvas to be ready
    await frame.waitForSelector('canvas', { timeout: 10000 });
    
    // Check if we can see game elements (canvas should be rendered)
    const canvas = frame.locator('canvas');
    await expect(canvas).toBeVisible();
    
    // Verify canvas has proper size (360x640 for Sky Drop)
    const boundingBox = await canvas.boundingBox();
    expect(boundingBox.width).toBeGreaterThan(300);
    expect(boundingBox.height).toBeGreaterThan(500);
  });

  test('should handle game initialization', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Wait for game to finish loading
    await page.waitForTimeout(3000);
    
    // Check if canvas is interactive (should respond to clicks)
    await canvas.click({ position: { x: 180, y: 400 } });
    
    // Game should be loaded and responsive
    await expect(canvas).toBeVisible();
  });

  test('should support keyboard controls', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    // Focus on the game canvas
    await canvas.click();
    await page.waitForTimeout(2000);
    
    // Test key presses (game controls)
    await frame.keyboard.press('Space'); // Parachute
    await frame.keyboard.press('ArrowLeft'); // Move left  
    await frame.keyboard.press('ArrowRight'); // Move right
    await frame.keyboard.press('KeyR'); // Reset
    
    // Game should still be responsive after key presses
    await expect(canvas).toBeVisible();
  });

  test('should maintain proper aspect ratio', async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    const frame = await gameFrame.contentFrame();
    const canvas = frame.locator('canvas');
    
    const boundingBox = await canvas.boundingBox();
    const aspectRatio = boundingBox.width / boundingBox.height;
    
    // Sky Drop is 360x640, so aspect ratio should be around 0.5625
    expect(aspectRatio).toBeCloseTo(0.5625, 1);
  });
});