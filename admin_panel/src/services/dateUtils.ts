export const formatToIST = (dateString: string | Date | undefined): string => {
  if (!dateString) return 'Unknown';
  try {
    let date: Date;
    if (typeof dateString === 'string') {
      let str = dateString;
      const hasTimezone = str.endsWith('Z') || /[+-]\d{2}:?\d{2}$/.test(str);
      if (!hasTimezone) {
        str = str + 'Z';
      }
      date = new Date(str);
    } else {
      date = dateString;
    }
    return date.toLocaleString('en-IN', {
      timeZone: 'Asia/Kolkata',
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
  } catch (e) {
    return 'Invalid Date';
  }
};

export const formatToISTDateOnly = (dateString: string | Date | undefined, options?: Intl.DateTimeFormatOptions): string => {
  if (!dateString) return 'Unknown';
  try {
    let date: Date;
    if (typeof dateString === 'string') {
      let str = dateString;
      const hasTimezone = str.endsWith('Z') || /[+-]\d{2}:?\d{2}$/.test(str);
      if (!hasTimezone) {
        str = str + 'Z';
      }
      date = new Date(str);
    } else {
      date = dateString;
    }
    return date.toLocaleDateString('en-IN', {
      timeZone: 'Asia/Kolkata',
      day: options?.day ?? 'numeric',
      month: options?.month ?? 'long',
      year: options?.year ?? 'numeric'
    });
  } catch (e) {
    return 'Invalid Date';
  }
};

export const formatToISTTimeOnly = (dateString: string | Date | undefined): string => {
  if (!dateString) return 'Unknown';
  try {
    let date: Date;
    if (typeof dateString === 'string') {
      let str = dateString;
      const hasTimezone = str.endsWith('Z') || /[+-]\d{2}:?\d{2}$/.test(str);
      if (!hasTimezone) {
        str = str + 'Z';
      }
      date = new Date(str);
    } else {
      date = dateString;
    }
    return date.toLocaleTimeString('en-IN', {
      timeZone: 'Asia/Kolkata',
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
  } catch (e) {
    return 'Invalid Date';
  }
};
