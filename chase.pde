/*敵オブジェクトの追従プログラム
ProcessingにPriority Queueが無いので計算量多め */

 void chasePlayer() {

  // プレイヤーの位置
  int targetX = playerX;
  int targetY = playerY;

  // 距離を無限大に初期化
  int[][] distances = new int[resY][resX];//resX,Yはマップの最大配列数

  for (int y = 0; y < resY; y++) {
    for (int x = 0; x < resX; x++) {

      distances[y][x] = Integer.MAX_VALUE;

    }
  }

  // 現在の敵の位置をスタート地点に設定
  distances[y][x] = 0;

  // 前の位置を記録する配列
  PVector[][] previous = new PVector[resY][resX];

  // まだ未訪問のセルを保持する2次元配列
  boolean[][] visited = new boolean[resY][resX];

  // 4方向の移動量
  int[] dx = {1, -1, 0, 0};
  int[] dy = {0, 0, 1, -1};

  while (true) {

    int shortestDist = Integer.MAX_VALUE;
    int bestX = -1;
    int bestY = -1;

    // 最小の距離を持つ未訪問のセルを探す
    for (int y = 0; y < resY; y++) {
      for (int x = 0; x < resX; x++) {

        if (!visited[y][x] && distances[y][x] < shortestDist) {

          shortestDist = distances[y][x];

          bestX = x;
          bestY = y;

        }
      }
    }

    // 最短距離のセルが見つからない場合、探索終了
    if (bestX == -1 || bestY == -1) {

      break;

    }

    // 最短距離のセルを訪問済みに設定
    visited[bestY][bestX] = true;

    // 4つの方向をチェック
    for (int i = 0; i < 4; i++) {

      int newX = bestX + dx[i];
      int newY = bestY + dy[i];

      // マップの端を超えないようにチェック
      if (newX >= 0 && newY >= 0 && newX < resX && newY < resY) {

        if (map[newY][newX] == 0) {  // 壁でない場合

          int newDist = shortestDist + 1;  // 現在の距離 + 移動コスト

          if (newDist < distances[newY][newX]) {

            distances[newY][newX] = newDist;

            previous[newY][newX] = new PVector(bestX, bestY);

          }
        }
      }
    }

    // プレイヤーの位置に到達した場合、探索終了
    if (bestX == targetX && bestY == targetY) {

      break;

    }
  }

  // プレイヤーへの経路が見つかった場合、新しい次の位置を設定
  PVector currentStep = new PVector(targetX, targetY);
  PVector nextStep = null;
  while (currentStep != null) {

    PVector prevStep = previous[(int)currentStep.y][(int)currentStep.x];

    if (prevStep != null && prevStep.x == x && prevStep.y == y) {

      nextStep = currentStep;

      break;

    }

    currentStep = prevStep;

  }

  if (nextStep != null) {

    x = (int)nextStep.x;
    y = (int)nextStep.y;

  }
}