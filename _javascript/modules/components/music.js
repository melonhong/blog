const musicbtn = document.getElementById('music-btn');
const musicPlayer = document.getElementById('music-player');
const overlay = document.getElementById('overlay');

export function showPlayer() {
  if (musicPlayer === null || overlay === null) return;

  musicPlayer.classList.remove('music-player-hidden');
  musicPlayer.classList.add('music-player-popup');
  musicPlayer.style.animation = 'fade-in 1s forwards';
  overlay.classList.remove('music-player-hidden');
}

export function removePlayer() {
  if (musicPlayer === null || overlay === null) return;

  musicPlayer.classList.add('music-player-hidden');
  overlay.classList.add('music-player-hidden');
}

if (musicbtn) {
  musicbtn.addEventListener('mouseenter', showPlayer);

  musicbtn.addEventListener('touchstart', (e) => {
    e.preventDefault();
    showPlayer();
  });
}

if (musicPlayer) {
  musicPlayer.addEventListener('mouseleave', removePlayer);
}

if (overlay) {
  overlay.addEventListener('click', removePlayer);
}
