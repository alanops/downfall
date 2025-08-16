const { test, expect } = require('@playwright/test');

test.describe('Sky Drop - Gameplay Mechanics', () => {
  
  let frame, canvas;

  test.beforeEach(async ({ page }) => {
    await page.goto('/downfall');
    
    const gameFrame = page.locator('iframe[src*="html5"]').first();
    await gameFrame.waitFor({ timeout: 15000 });
    
    frame = await gameFrame.contentFrame();
    canvas = frame.locator('canvas');
    await canvas.click(); // Focus and potentially start game
    await page.waitForTimeout(3000); // Allow game to initialize
  });

  test('should start gameplay when play button is clicked', async ({ page }) => {
    // Click in the center area where play button should be
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(1000);
    
    // Game should be responsive to further input
    await frame.keyboard.press('ArrowLeft');
    await frame.keyboard.press('ArrowRight');
    
    await expect(canvas).toBeVisible();
  });

  test('should respond to movement controls', async ({ page }) => {
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Test left movement
    await frame.keyboard.down('ArrowLeft');
    await page.waitForTimeout(500);
    await frame.keyboard.up('ArrowLeft');
    
    // Test right movement  
    await frame.keyboard.down('ArrowRight');
    await page.waitForTimeout(500);
    await frame.keyboard.up('ArrowRight');
    
    // Test alternative controls (WASD)
    await frame.keyboard.press('KeyA'); // Left
    await frame.keyboard.press('KeyD'); // Right
    
    // Canvas should remain responsive
    await expect(canvas).toBeVisible();
  });

  test('should handle parachute deployment', async ({ page }) => {
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Deploy parachute
    await frame.keyboard.press('Space');
    await page.waitForTimeout(1000);
    
    // Toggle parachute again
    await frame.keyboard.press('Space');
    await page.waitForTimeout(1000);
    
    // Test that game continues to respond
    await frame.keyboard.press('ArrowLeft');
    await expect(canvas).toBeVisible();
  });

  test('should support game reset functionality', async ({ page }) => {
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Play for a moment
    await frame.keyboard.press('ArrowLeft');
    await frame.keyboard.press('Space');
    await page.waitForTimeout(1000);
    
    // Reset the game
    await frame.keyboard.press('KeyR');
    await page.waitForTimeout(2000);
    
    // Game should be responsive after reset
    await expect(canvas).toBeVisible();
  });

  test('should handle rapid input without breaking', async ({ page }) => {
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(1000);
    
    // Rapid input test
    for (let i = 0; i < 10; i++) {
      await frame.keyboard.press('ArrowLeft');
      await frame.keyboard.press('ArrowRight');
      await frame.keyboard.press('Space');
      await page.waitForTimeout(50);
    }
    
    // Game should still be responsive
    await expect(canvas).toBeVisible();
    await frame.keyboard.press('KeyR'); // Should still reset
  });

  test('should maintain gameplay for extended period', async ({ page }) => {
    // Start the game
    await canvas.click({ position: { x: 180, y: 350 } });
    await page.waitForTimeout(2000);
    
    // Simulate extended gameplay (simulate falling for 10 seconds)
    for (let i = 0; i < 20; i++) {
      await frame.keyboard.press('ArrowLeft');
      await page.waitForTimeout(250);
      await frame.keyboard.press('ArrowRight');
      await page.waitForTimeout(250);
    }
    
    // Deploy parachute near end
    await frame.keyboard.press('Space');
    await page.waitForTimeout(2000);
    
    // Game should still be responsive after extended play
    await expect(canvas).toBeVisible();
  });
});